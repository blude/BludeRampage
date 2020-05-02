//
//  Tile.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Tile: Int, Decodable {
    case floor, wall
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall:
            return true
        case .floor:
            return false
        }
    }
}
