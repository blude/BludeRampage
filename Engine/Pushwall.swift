//
//  Pushwall.swift
//  Engine
//
//  Created by Saulo Pratti on 14.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Pushwall {
    public var position: Vector
    public var velocity: Vector
    public let speed: Double = 0.25
    public let tile: Tile
    
    public init(position: Vector, tile: Tile) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
        self.tile = tile
    }
}

public extension Pushwall {
    var rect: Rect {
        Rect(
            min: position - Vector(x: 0.5, y: 0.5),
            max: Vector(x: 0.5, y: 0.5)
        )
    }
    
    var billboards: [Billboard] {
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
        ]
    }
    
    var isMoving: Bool {
        velocity.x != 0 || velocity.y != 0
    }
    
    mutating func update(in world: inout World) {
        if isMoving == false, let intersection = world.player.intersection(with: self) {
            if abs(intersection.x) > abs(intersection.y) {
                velocity = Vector(x: intersection.x > 0 ? speed : -speed, y: 0)
            } else {
                velocity = Vector(x: 0, y: intersection.y > 0 ? speed : -speed)
            }
        }
    }
}
