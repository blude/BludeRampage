//
//  Pushwall.swift
//  Engine
//
//  Created by Saulo Pratti on 14.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Pushwall: Actor {
    public var position: Vector
    public var velocity: Vector
    public let speed: Double = 0.25
    public let radius: Double = 0.5
    public let tile: Tile
    public let soundChannel: Int
    
    public init(position: Vector, tile: Tile, soundChannel: Int) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
        self.tile = tile
        self.soundChannel = soundChannel
    }
}

public extension Pushwall {
    var isDead: Bool {
        return false
    }
    
    var isMoving: Bool {
        return velocity.x != 0 || velocity.y != 0
    }
    
    func billboards(facing viewpoint: Vector) -> [Billboard] {
        let topLeft = rect.min
        let bottomRight = rect.max
        let topRight = Vector(x: bottomRight.x, y: topLeft.y)
        let bottomLeft = Vector(x: topLeft.x, y: bottomRight.y)
        let textures = tile.textures
        
        return [
            Billboard(start: topLeft, direction: Vector(x: 0, y: 1), length: 1, texture: textures[0]),
            Billboard(start: topRight, direction: Vector(x: -1, y: 0), length: 1, texture: textures[1]),
            Billboard(start: bottomRight, direction: Vector(x: 0, y: -1), length: 1, texture: textures[0]),
            Billboard(start: bottomLeft, direction: Vector(x: 1, y: 0), length: 1, texture: textures[1])
        ].filter { billboard in
            let ray = billboard.start - viewpoint
            let faceNormal = billboard.direction.orthogonal
            return ray.dot(faceNormal) < 0
        }
    }
    
    mutating func update(in world: inout World) {
        let wasMoving = isMoving
        
        if isMoving == false, let intersection = world.player.intersection(with: self) {
            let direction: Vector
            
            if abs(intersection.x) > abs(intersection.y) {
                direction = Vector(x: intersection.x > 0 ? 1 : -1, y: 0)
            } else {
                direction = Vector(x: 0, y: intersection.y > 0 ? 1 : -1)
            }
            
            let x = Int(position.x + direction.x)
            let y = Int(position.y + direction.y)
            
            if world.map[x, y].isWall == false {
                velocity = direction * speed
            }
        }
        
        if let intersection = self.intersection(with: world),
            abs(intersection.x) > 0.001 || abs(intersection.y) > 0.001 {
            velocity = Vector(x: 0, y: 0)
            position.x = position.x.rounded(.down) + 0.5
            position.y = position.y.rounded(.down) + 0.5
        }
        
        if isMoving {
            world.playSound(.wallSlide, at: position, in: soundChannel)
        } else if !isMoving {
            world.playSound(nil, at: position, in: soundChannel)
            if wasMoving {
                world.playSound(.wallThud, at: position)
            }
        }
    }
}
