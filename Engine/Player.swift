//
//  Player.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Player {
    public let speed: Double = 2
    public let radius: Double = 0.25
    public var position: Vector
    public var velocity: Vector
    
    public init(position: Vector) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
    }
}

public extension Player {
    var rect: Rect {
        let halfSize = Vector(x: radius, y: radius)
        return Rect(min: position - halfSize, max: position + halfSize)
    }
    
    func isIntersecting(map: Tilemap) -> Bool {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        
        for y in minY ... maxY {
            for x in minX ... maxX {
                if map[x, y].isWall {
                    return true
                }
            }
        }
        return false
    }
}
