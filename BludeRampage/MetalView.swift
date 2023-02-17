//
//  MetalView.swift
//  BludeRampage
//
//  Created by Saulo Pratti on 06.02.21.
//  Copyright © 2021 Pratti Design. All rights reserved.
//

import UIKit
import MetalKit
import Engine
import Renderer
import simd
import os

let fizzle = Bitmap(height: 128, pixels: {
    var colors = [Color]()
    colors.reserveCapacity(128 * 128)

    for _ in 0 ..< 64 {
        for i: UInt8 in 0 ... 255 {
            colors.append(Color(r: 255, g: 255, b: 255, a: 1))
        }
    }
        
    return colors.shuffled()
}())

class MetalView: MTKView {
    private lazy var renderer = Renderer(metalView: self)
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        setUp()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        device = device ?? MTLCreateSystemDefaultDevice()
        renderer?.mtkView(self, drawableSizeWillChange: drawableSize)
        isPaused = true
        delegate = renderer
    }
    
    func draw(_ game: Game) {
        renderer?.game = game
        draw()
    }
}

let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100
let maxBuffersInFlight = 3

struct Vertex {
    var position: SIMD3<Float>
    var texcoord: SIMD2<Float> = SIMD2(0, 0)
    var color: SIMD4<UInt8> = SIMD4(255, 255, 255, 255)
}

extension CGPoint {
    init(_ vector: Vector) {
        self.init(x: vector.x, y: vector.y)
    }
}

extension Vector {
    init(_ point: CGPoint) {
        self.init(x: Double(point.x), y: Double(point.y))
    }
}

enum Orientation {
    case up, down, forwards, backwards, left, right
    case billboard(end: CGPoint)
    case view(size: CGSize, xRange: (Float, Float))
    case overlay(opacity: Double, effect: EffectType)
}

struct Quad {
    var texture: Texture!
    var position: CGPoint
    var orientation: Orientation
    var translucent = false
    var tintColor = Color.white
}

private class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    let dynamicUniformBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let orthoPipelineState: MTLRenderPipelineState
    let effectPipelineState: MTLRenderPipelineState
    let fizzlePipelineState: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    let spriteDepthState: MTLDepthStencilState
    let overlayDepthState: MTLDepthStencilState
    
    var uniformBufferOffset = 0
    var uniformBufferIndex = 0
    var uniforms: UnsafeMutablePointer<Uniforms>
    var projectionMatrix = matrix_float4x4()
    var textures = [Texture: MTLTexture]()
    var fizzleTexture: MTLTexture
    
    var vertexBuffer: MTLBuffer!
    
    var quads = [Quad]()
    var vertexData = [Vertex]()
    var viewTransform = matrix_identity_float4x4
    var orthoTransform = matrix_identity_float4x4
    var playerPosition: Vector?
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    
    var bounds = CGSize.zero
    var safeAreaInsets = UIEdgeInsets.zero
    var game: Game?
    
    // MARK: Setup
    
    init?(metalView: MetalView) {
        guard let device = metalView.device,
              let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        self.device = device
        self.commandQueue = commandQueue
        
        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        guard let buffer = self.device.makeBuffer(length: uniformBufferSize, options: [.storageModeShared]) else {
            return nil
        }
        
        dynamicUniformBuffer = buffer
        dynamicUniformBuffer.label = "UniformBuffer"
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)
        
        metalView.depthStencilPixelFormat = .depth32Float_stencil8
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.sampleCount = 1
        
        do {
            pipelineState = try Self.buildRenderPipeline(device: device, vertexShader: "vertexShader", fragmentShader: "fragmentShader", metalKitView: metalView)
            orthoPipelineState = try Self.buildRenderPipeline(device: device, vertexShader: "vertexShader", fragmentShader: "fragmentShader", metalKitView: metalView)
            effectPipelineState = try Self.buildRenderPipeline(device: device, vertexShader: "vertexShader", fragmentShader: "fragmentShader", metalKitView: metalView)
            fizzlePipelineState = try Self.buildRenderPipeline(device: device, vertexShader: "vertexShader", fragmentShader: "fragmentShader", metalKitView: metalView)

            let depthStateDescriptor = MTLDepthStencilDescriptor()
            depthStateDescriptor.depthCompareFunction = MTLCompareFunction.lessEqual
            
            depthStateDescriptor.isDepthWriteEnabled = true
            guard let state = device.makeDepthStencilState(descriptor: depthStateDescriptor) else {
                return nil
            }
            depthState = state
            
            depthStateDescriptor.isDepthWriteEnabled = false
            guard let state2 = device.makeDepthStencilState(descriptor: depthStateDescriptor) else {
                return nil
            }
            spriteDepthState = state2
            
            depthStateDescriptor.depthCompareFunction = .always
            guard let state3 = device.makeDepthStencilState(descriptor: depthStateDescriptor) else {
                return nil
            }
            overlayDepthState = state3
            
            fizzleTexture = try Self.loadTexture(device: device, bitmap: fizzle)
        } catch {
            print("Unable to initialize Metal. Error info: \(error)")
            return nil
        }
        
        super.init()
    }

    // MARK: MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        bounds = size
        let aspect = Float(size.width) / Float(size.height)
        projectionMatrix = matrixPerspectiveRightHand(fovyRadians: radiansFromDegrees(35), aspectRatio: aspect, nearZ: 0.1, farZ: 100)
    }
    
    func draw(in view: MTKView) {
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let game = game else {
            return
        }
        
        commandBuffer.addCompletedHandler { [inFlightSemaphore] _ in
            inFlightSemaphore.signal()
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let drawable = view.currentDrawable else {
            return
        }
        
        updateDynamicBufferState()
        uniforms[0] = Uniforms(projectionMatrix: projectionMatrix, modelViewMatrix: Self.viewTransform(for: game.world), orthoMatrix: matrixOrtho(width: Float(bounds.width), height: Float(bounds.height)))
        
        quads.removeAll()
        draw(game)
        
        renderEncoder.setCullMode(.back)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setVertexBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
        
        var sprites = [Quad]()
        for (textureID, quads) in sortByTexture(self.quads) {
            switch quads[0].orientation {
            case .view, .overlay:
                continue
            case .billboard,
                 _ where quads[0].translucent:
                sprites += quads
                continue
            default:
                break
            }
            if let texture = textures[textureID] ??
                (try? Renderer.loadTexture(device: device, textureName: textureID.rawValue)) {
                renderEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)
                textures[textureID] = texture
            }
            var vertexData = getVertexData(for: quads)
            vertexBuffer = device.makeBuffer(bytes: &vertexData, length: vertexData.count * MemoryLayout<Vertex>.stride, options: .storageModeShared)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
        }
        
        renderEncoder.setCullMode(.none)
        renderEncoder.setDepthStencilState(spriteDepthState)
        let playerPosition = game.world.player.position
        for quad in sprites.sorted(by: {
            (Vector($0.position) - playerPosition).length > (Vector($1.position) - playerPosition).length
        }) {
            let textureID = quad.texture!
            if let texture = textures[textureID] ?? (try? Renderer.loadTexture(device: device, textureName: textureID.rawValue)) {
                renderEncoder.setFragmentTexture(texture, index: TextureIndex.color.rawValue)
                textures[textureID] = texture
            }
            var vertexData = getVertexData(for: [quad])
            vertexBuffer = device.makeBuffer(bytes: &vertexData, length: vertexData.count * MemoryLayout<Vertex>.stride, options: .storageModeShared)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: Drawing
    
    func draw(_ game: Game) {
        switch game.state {
        case .title, .starting:
            break
        case .playing:
            break
        }
    }
    
    func draw(_ world: World) {
        //
    }
    
    func draw(_ hud: HUD) {
        //
    }
    
    func draw(_ effect: Effect) {
        switch effect.type {
        case .fadeIn:
            quads.append(Quad(texture: nil, position: .zero, orientation: .overlay(opacity: 1 - effect.progress, effect: effect.type), tintColor: effect.color))
        case .fadeOut, .fizzleOut:
            quads.append(Quad(texture: nil, position: .zero, orientation: .overlay(opacity: effect.progress, effect: effect.type), tintColor: effect.color))
        }
    }
    
    // MARK: Utilities
    
    func sortByTexture(_ quads: [Quad]) -> [Texture: [Quad]] {
        var groups = [Texture: [Quad]]()
        for quad in quads where quad.texture != nil {
            groups[quad.texture, default: []].append(quad)
        }
        return groups
    }
    
    func makeQuad(_ a: SIMD3<Float>, _ b: SIMD3<Float>,
                  _ c: SIMD3<Float>, _ d: SIMD3<Float>,
                  u1: Float = 0, u2: Float = 1, color: Color) -> [Vertex] {
        let color = SIMD4<UInt8>(color.r, color.b, color.g, color.a)
        return [
            Vertex(position: a, texcoord: SIMD2(u1, 1), color: color),
            Vertex(position: b, texcoord: SIMD2(u2, 1), color: color),
            Vertex(position: c, texcoord: SIMD2(u2, 0), color: color),
            Vertex(position: c, texcoord: SIMD2(u2, 0), color: color),
            Vertex(position: d, texcoord: SIMD2(u1, 0), color: color),
            Vertex(position: a, texcoord: SIMD2(u1, 1), color: color)
        ]
    }
    
    func getVertexData(for quads: [Quad]) -> [Vertex] {
        var vertexData = [Vertex]()
        vertexData.reserveCapacity(quads.count * 6)
        
        for quad in quads {
            let x = Float(quad.position.x),
                y = Float(quad.position.y)

            switch quad.orientation {
            case .up, .down, .left, .right:
                break
            case .backwards, .forwards:
                break
            case .billboard(end: let end):
                let x2 = Float(end.x), y2 = Float(end.y)
                vertexData += makeQuad(
                    SIMD3(x, -0.5, y),
                    SIMD3(x2, -0.5, y2),
                    SIMD3(x2, 0.5, y2),
                    SIMD3(x, 0.5, y),
                    color: quad.tintColor
                )
            case .view(size: let size, xRange: let (u1, u2)):
                let x2 = x + Float(size.width), y2 = y + Float(size.height)
                vertexData += makeQuad(
                    SIMD3(x, y2, 0),
                    SIMD3(x2, y2, 0),
                    SIMD3(x2, y, 0),
                    SIMD3(x, y, 0),
                    u1: u1,
                    u2: u2,
                    color: quad.tintColor
                )
            case .overlay(opacity: let opacity, effect: _):
                let color = Color(r: quad.tintColor.r, g: quad.tintColor.g, b: quad.tintColor.b, a: UInt8(min(255, Double(quad.tintColor.a) * opacity)))
                let size = Float(max(bounds.width, bounds.height))
                vertexData += makeQuad(
                    SIMD3(0, 0, 0),
                    SIMD3(size, 0, 0),
                    SIMD3(size, size, 0),
                    SIMD3(0, size, 0),
                    color: color
                )
            }
        }
        
        return vertexData
    }
    
    static func buildRenderPipeline(device: MTLDevice, vertexShader: String, fragmentShader: String, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: vertexShader)
        let fragmentFunction = library?.makeFunction(name: fragmentShader)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.sampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    static func loadTexture(device: MTLDevice, textureName: String) throws -> MTLTexture {
        /// Load texture data with optimal parameters for sampling
        let textureLoader = MTKTextureLoader(device: device)
        
        let options: [MTKTextureLoader.Option: Any] = [
            .textureUsage: MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode: MTLStorageMode.private.rawValue,
            .SRGB: false,
        ]
        
        return try textureLoader.newTexture(name: textureName, scaleFactor: 1.0, bundle: nil, options: options)
    }
    
    static func loadTexture(device: MTLDevice, bitmap: Bitmap) throws -> MTLTexture {
        /// Load texture data with optimal parameters for sampling
        let textureLoader = MTKTextureLoader(device: device)
        
        let options: [MTKTextureLoader.Option: Any] = [
            .textureUsage: MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode: MTLStorageMode.private.rawValue,
            .SRGB: false
        ]
        
        let image = UIImage(bitmap: bitmap)?.cgImage
        
        return try textureLoader.newTexture(cgImage: image!, options: options)
    }
    
    private func updateDynamicBufferState() {
        /// Update the state of our uniform buffers before rendering
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to: Uniforms.self, capacity: 1)
    }
    
    static func viewTransform(for world: World) -> matrix_float4x4 {
        let angle = atan2(world.player.direction.x, -world.player.direction.y)
        let rotation = matrix4x4Rotation(radians: Float(angle), axis: SIMD3(0, 1, 0))
        let translation = matrix4x4Translation(-Float(world.player.position.x), 0, -Float(world.player.position.y))
        
        return matrix_multiply(rotation, translation)
    }
}

// MARK: Generic matrix math utility functions

func matrix4x4Rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    
    return matrix_float4x4(columns: (
        vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
        vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
        vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
        vector_float4(                  0,                   0,                   0, 1)
    ))
}

func matrix4x4Translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4(columns: (
        vector_float4(1, 0, 0, 0),
        vector_float4(0, 1, 0, 0),
        vector_float4(0, 0, 1, 0),
        vector_float4(translationX, translationY, translationZ, 1)
    ))
}

func matrix4x4Scale(_ scaleX: Float, _ scaleY: Float) -> matrix_float4x4 {
    return matrix_float4x4(columns: (
        vector_float4(scaleX, 0, 0, 0),
        vector_float4(0, scaleY, 0, 0),
        vector_float4(0, 0, 1, 0),
        vector_float4(0, 0, 0, 1)
    ))
}

func matrixPerspectiveRightHand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return matrix_float4x4(columns: (
        vector_float4(xs, 0, 0, 0),
        vector_float4(0, ys, 0, 0),
        vector_float4(0, 0, zs, -1),
        vector_float4(0, 0, zs * nearZ, 0)
    ))
}

func matrixOrtho(width: Float, height: Float) -> matrix_float4x4 {
    return matrix_multiply(matrix4x4Translation(-1, 1, 0), matrix4x4Scale(2 / width, -2 / height))
}

func radiansFromDegrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}
