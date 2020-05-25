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
        var emptyTiles = Set<Vector>()
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall == false, map[thing: x, y] == .nothing {
                    emptyTiles.insert(Vector(x: Double(x) + 0.5, y: Double(y) + 0.5))
                }
            }
        }
        
        // MARK: Add monsters
        for _ in 0 ..< (mapData.monsters ?? 0) {
            if let position = emptyTiles.randomElement() {
                let x = Int(position.x)
                let y = Int(position.y)
                map[thing: x, y] = .monster
                emptyTiles.remove(position)
            }
        }
    }
}
