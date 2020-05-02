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

    subscript(x: Int, y: Int) -> Tile {
        tiles[y * width + x]
    }
}
