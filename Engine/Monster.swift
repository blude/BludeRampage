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
    public var state: MonsterState = .idle
    public let radius: Double = 0.4375 // Equal to: 14 / 16 / 2
    
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
        case .chasing:
            guard canSeePlayer(in: world) else {
                state = .idle
                break
            }
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
