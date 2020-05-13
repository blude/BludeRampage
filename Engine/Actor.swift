//
//  Actor.swift
//  Engine
//
//  Created by Saulo Pratti on 09.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public protocol Actor {
    var radius: Double { get }
    var position: Vector { get set }
    var isDead: Bool { get }
}

public extension Actor {
    var rect: Rect {
        let halfSize = Vector(x: radius, y: radius)
        return Rect(min: position - halfSize, max: position + halfSize)
    }
    
    func intersection(with map: Tilemap) -> Vector? {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        var largestIntersection: Vector?
        
        for y in minY ... maxY {
            for x in minX ... maxX where map[x, y].isWall {
                let wallRect = Rect(
                    min: Vector(x: Double(x), y: Double(y)),
                    max: Vector(x: Double(x + 1), y: Double(y + 1))
                )
                if let intersection = rect.intersection(with: wallRect),
                    intersection.length > largestIntersection?.length ?? 0 {
                    largestIntersection = intersection
                }
            }
        }
        
        return largestIntersection
    }
    
    func intersection(with door: Door) -> Vector? {
        rect.intersection(with: door.rect)
    }
    
    func intersection(with world: World) -> Vector? {
        if let intersection = intersection(with: world.map) {
            return intersection
        }
        for door in world.doors {
            if let intersection = intersection(with: door) {
                return intersection
            }
        }
        return nil
    }
    
    func intersection(with actor: Actor) -> Vector? {
        if isDead || actor.isDead {
            return nil
        }
        return rect.intersection(with: actor.rect)
    }
}
