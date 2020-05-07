//
//  Tile.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Tile: Int, Decodable {
    case floor = 0
    case crackFloor = 4
    
    case wall = 1
    case crackWall = 2
    case slimeWall = 3
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall, .crackWall, .slimeWall:
            return true
        case .floor, .crackFloor:
            return false
        }
    }
    
    var textures: [Texture] {
        switch self {
        case .floor:
            return [.floor, .ceiling]
        case .crackFloor:
            return [.crackFloor, .ceiling]
        case .wall:
            return [.wall, .wall2]
        case .crackWall:
            return [.crackWall, .crackWall2]
        case .slimeWall:
            return [.slimeWall, .slimeWall2]
        }
    }
}
