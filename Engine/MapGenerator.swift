//
//  MapGenerator.swift
//  Engine
//
//  Created by Saulo Pratti on 26.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct MapGenerator {
    public private(set) var map: Tilemap
    private var playerPosition: Vector!
    private var emptyTiles: Set<Vector> = []
    
    public init(mapData: MapData, index: Int) {
        self.map = Tilemap(mapData, index: index)
        
        // MARK: Find empty tiles
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
        
        // MARK: Add doors
        for position in emptyTiles {
            let (x, y) = (
                Int(position.x), Int(position.y)
            )
            let (left, right, up, down) = (
                map[x - 1, y], map[x + 1, y],
                map[x, y - 1], map[x, y + 1]
            )
            
            if (left.isWall && right.isWall && !up.isWall && !down.isWall)
                || (!left.isWall && !right.isWall && up.isWall && down.isWall) {
                add(.door, at: position)
            }
        }
        
        // MARK: Add monsters
        for _ in 0 ..< (mapData.monsters ?? 0) {
            add(.monster, at: emptyTiles.filter({
                (playerPosition - $0).length > 2.5
            }).randomElement())
        }
        
        // MARK: Add medkits
        for _ in 0 ..< (mapData.medkits ?? 0) {
            add(.medkit, at: emptyTiles.randomElement())
        }
        
        // MARK: Add shotguns
        for _ in 0 ..< (mapData.shotguns ?? 0) {
            add(.shotgun, at: emptyTiles.randomElement())
        }
    }
}

private extension MapGenerator {
    mutating func add(_ thing: Thing, at position: Vector?) {
        if let position = position {
            map[thing: Int(position.x), Int(position.y)] = thing
            emptyTiles.remove(position)
        }
    }
}
