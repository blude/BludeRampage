//
//  Monster.swift
//  Engine
//
//  Created by Saulo Pratti on 08.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum MonsterState {
    case idle, chasing
}

public struct Monster: Actor {
    public var position: Vector
    public var velocity: Vector = Vector(x: 0, y: 0)
    public var state: MonsterState = .idle
    public let radius: Double = 0.4375 // Equal to: 14 / 16 / 2
    public let speed: Double = 0.5
    
    public init(position: Vector) {
        self.position = position
    }
}

public extension Monster {
    mutating func update(in world: World) {
        switch state {
        case .idle:
            if canSeePlayer(in: world) {
                state = .chasing
            }
            velocity = Vector(x: 0, y: 0)
        case .chasing:
            guard canSeePlayer(in: world) else {
                state = .idle
                break
            }
            let direction = world.player.position - position
            velocity = direction * (speed / direction.length)
        }
    }
    
    func canSeePlayer(in world: World) -> Bool {
        let direction = world.player.position - position
        let playerDistance = direction.length
        let ray = Ray(origin: position, direction: direction / playerDistance)
        let wallHit = world.map.hitTest(ray)
        let wallDistance = (wallHit - position).length
        
        return wallDistance > playerDistance
    }
}
