//
//  MapGenerator.swift
//  Engine
//
//  Created by Saulo Pratti on 26.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct MapGenerator {
    public private(set) var map: Tilemap
    
    public init(mapData: MapData, index: Int) {
        self.map = Tilemap(mapData, index: index)
        
        // MARK: Find empty tiles
        var playerPosition: Vector!
        var emptyTiles = Set<Vector>()
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let position = Vector(x: Double(x) + 0.5, y: Double(y) + 0.5)
                if map[x, y].isWall == false {
                    switch map[thing: x, y] {
                    case .nothing:
                        emptyTiles.insert(position)
                    case .player:
                        playerPosition = position
                    default:
                        break
                    }
                }
            }
        }
        
        // MARK: Add monsters
        for _ in 0 ..< (mapData.monsters ?? 0) {
            if let position = emptyTiles.filter({ tile in
                (playerPosition - tile).length > 2.5
            }).randomElement() {
                let x = Int(position.x)
                let y = Int(position.y)
                map[thing: x, y] = .monster
                emptyTiles.remove(position)
            }
        }
        
        // MARK: Add medkits
        for _ in 0 ..< (mapData.medkits ?? 0) {
            if let position = emptyTiles.filter({ tile in
                (playerPosition - tile).length > 2.5
            }).randomElement() {
                let x = Int(position.x)
                let y = Int(position.y)
                map[thing: x, y] = .medkit
                emptyTiles.remove(position)
            }
        }
    }
}
