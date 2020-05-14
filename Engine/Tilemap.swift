//
//  Tilemap.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Tilemap: Decodable {
    private let tiles: [Tile]
    public let things: [Thing]
    public let width: Int
}

public extension Tilemap {
    var height: Int {
        tiles.count / width
    }
    
    var size: Vector {
        Vector(x: Double(width), y: Double(height))
    }
    
    func tileCoords(at position: Vector, from direction: Vector) -> (x: Int, y: Int) {
        var offsetX = 0, offsetY = 0
        
        if position.x.rounded(.down) == position.x {
            offsetX = direction.x > 0 ? 0 : -1
        }
        
        if position.y.rounded(.down) == position.y {
            offsetY = direction.y > 0 ? 0 : -1
        }
        
        return (x: Int(position.x) + offsetX, y: Int(position.y) + offsetY)
    }
    
    func tile(at position: Vector, from direction: Vector) -> Tile {
        let (x, y) = tileCoords(at: position, from: direction)
        return self[x, y]
    }
    
    func hitTest(_ ray: Ray) -> Vector {
        var position = ray.origin
        let slope = ray.direction.x / ray.direction.y
        
        repeat {
            let edgeDistanceX, edgeDistanceY: Double
            
            if ray.direction.x > 0 {
                edgeDistanceX = position.x.rounded(.down) + 1 - position.x
            } else {
                edgeDistanceX = position.x.rounded(.up) - 1 - position.x
            }
            
            if ray.direction.y > 0 {
                edgeDistanceY = position.y.rounded(.down) + 1 - position.y
            } else {
                edgeDistanceY = position.y.rounded(.up) - 1 - position.y
            }
            
            let step1 = Vector(x: edgeDistanceX, y: edgeDistanceX / slope)
            let step2 = Vector(x: edgeDistanceY * slope, y: edgeDistanceY)
            
            if step1.length < step2.length {
                position += step1
            } else {
                position += step2
            }
        } while tile(at: position, from: ray.direction).isWall == false
        
        return position
    }

    subscript(x: Int, y: Int) -> Tile {
        tiles[y * width + x]
    }
}
