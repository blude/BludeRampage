//
//  World.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct World {
    public let map: Tilemap
    public var player: Player!
    public var monsters: [Monster]
    
    public init(map: Tilemap) {
        self.map = map
        self.monsters = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let position = Vector(x: Double(x) + 0.5, y: Double(y) + 0.5)
                let thing = map.things[y * map.width + x]
                switch thing {
                case .nothing:
                    break
                case .player:
                    self.player = Player(position: position)
                case .monster:
                    self.monsters.append(Monster(position: position))
                }
            }
        }
    }
}

public extension World {
    var size: Vector {
        map.size
    }
    
    var sprites: [Billboard] {
        let spritePlane = player.direction.orthogonal
        return monsters.map { monster in
            Billboard(
                start: monster.position - spritePlane / 2,
                direction: spritePlane,
                length: 1
            )
        }
    }
    
    mutating func update(timeStep: Double, input: Input) {
        player.direction = player.direction.rotated(by: input.rotation)
        player.velocity = player.direction * input.speed * player.speed
        player.position += player.velocity * timeStep
        
        // Handle collisions
        for i in monsters.indices {
            var monster = monsters[i]
            if let intersection = player.intersection(with: monster) {
                player.position -= intersection / 2
                monster.position -= intersection / 2
            }
            while let intersection = monster.intersection(with: map) {
                monster.position -= intersection
            }
            monsters[i] = monster
        }
        
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }
}
