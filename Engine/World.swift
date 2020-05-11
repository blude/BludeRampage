//
//  World.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct World {
    public let map: Tilemap
    public private(set) var player: Player!
    public private(set) var monsters: [Monster]
    public private(set) var effects: [Effect]
    
    public init(map: Tilemap) {
        self.map = map
        self.monsters = []
        self.effects = []
        reset()
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
                length: 1,
                texture: monster.animation.texture
            )
        }
    }
    
    mutating func update(timeStep: Double, input: Input) {
        // MARK: Update effects
        effects = effects.compactMap { effect in
            if effect.isCompleted {
                return nil
            }
            var effect = effect
            effect.time += timeStep
            return effect
        }
        
        // MARK: Update player
        if player.isDead == false {
            player.direction = player.direction.rotated(by: input.rotation)
            player.velocity = player.direction * input.speed * player.speed
            player.position += player.velocity * timeStep
        } else if effects.isEmpty {
            effects.append(Effect(type: .fadeIn, color: .red, duration: 0.5))
            reset()
            return
        }
        
        // MARK: Update monsters
        for i in 0 ..< monsters.count {
            var monster = monsters[i]
            monster.update(in: &self)
            monster.position += monster.velocity * timeStep
            monster.animation.time += timeStep
            monsters[i] = monster
        }
        
        // Handle collisions
        for i in 0 ..< monsters.count {
            var monster = monsters[i]
            
            if let intersection = player.intersection(with: monster) {
                player.position -= intersection / 2
                monster.position += intersection / 2
            }
            
            for j in i + 1 ..< monsters.count {
                if let intersection = monster.intersection(with: monsters[j]) {
                    monster.position -= intersection / 2
                    monsters[j].position += intersection / 2
                }
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
    
    mutating func hurtPlayer(_ damage: Double) {
        if player.isDead {
            return
        }
        player.health -= damage
        let customRed = Color(r: 255, g: 0, b: 0, a: 191)
        effects.append(Effect(type: .fadeIn, color: customRed, duration: 0.2))
        if player.isDead {
            effects.append(Effect(type: .fizzleOut, color: .red, duration: 2))
        }
    }
    
    mutating func reset() {
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
                    monsters.append(Monster(position: position))
                }
            }
        }
    }
}
