//
//  Monster.swift
//  Engine
//
//  Created by Saulo Pratti on 08.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum MonsterState {
    case idle, chasing, scratching, blocked
    case hurt, dead
}

public struct Monster: Actor {
    public var position: Vector
    public var velocity: Vector = Vector(x: 0, y: 0)
    public var state: MonsterState = .idle
    public var animation: Animation = .monsterIdle
    public let radius: Double = 0.4375 // Equal to: 14 / 16 / 2
    public let speed: Double = 0.5
    public let attackCooldown: Double = 0.4
    public private(set) var lastAttackTime: Double = 0
    public private(set) var lastKnownPlayerPosition: Vector?
    public var health: Double = 50
    
    public init(position: Vector) {
        self.position = position
    }
}

public extension Monster {
    var isDead: Bool {
        health <= 0
    }
    
    mutating func update(in world: inout World) {
        switch state {
        case .idle:
            if canSeePlayer(in: world) {
                world.playSound(.monsterGroan, at: position)
                state = .chasing
                animation = .monsterWalk
            }
        case .chasing:
            if canSeePlayer(in: world) {
                lastKnownPlayerPosition = world.player.position
                if canReachPlayer(in: world) {
                    state = .scratching
                    animation = .monsterScratch
                    lastAttackTime = -attackCooldown
                    velocity = Vector(x: 0, y: 0)
                    break
                }
            }
            guard let destination = lastKnownPlayerPosition else {
                break
            }
            let direction = destination - position
            velocity = direction * (speed / direction.length)
            if world.monsters.contains(where: isBlocked(by:)) {
                state = .blocked
                animation = .monsterBlocked
                velocity = Vector(x: 0, y: 0)
            }
        case .blocked:
            if animation.isCompleted {
                state = .chasing
                animation = .monsterWalk
            }
        case .scratching:
            guard canReachPlayer(in: world) else {
                state = .chasing
                animation = .monsterWalk
                break
            }
            if animation.time - lastAttackTime >= attackCooldown {
                lastAttackTime = animation.time
                world.hurtPlayer(10)
                world.playSound(.monsterSwipe, at: position)
            }
        case .hurt:
            if animation.isCompleted {
                state = .chasing
                animation = .monsterWalk
            }
        case .dead:
            if animation.isCompleted {
                animation = .monsterDead
            }
        }
    }
    
    func isBlocked(by other: Monster) -> Bool {
        // Ignore dead or inactive monsters
        if other.isDead || other.state != .chasing {
            return false
        }
        
        // Ignore if too far away
        let direction = other.position - position
        let distance = direction.length
        let threshold = 0.5
        if distance > radius + other.radius + threshold {
            return false
        }
        
        // Is standing in the direction we're moving
        return (direction / distance).dot(velocity / velocity.length) > threshold
    }
    
    func canSeePlayer(in world: World) -> Bool {
        let direction = world.player.position - position
        let playerDistance = direction.length
        let ray = Ray(origin: position, direction: direction / playerDistance)
        let wallHit = world.hitTest(ray)
        let wallDistance = (wallHit - position).length
        
        return wallDistance > playerDistance
    }
    
    func canReachPlayer(in world: World) -> Bool {
        let reach = 0.25
        let playerDistance = (world.player.position - position).length
        return playerDistance - radius - world.player.radius < reach
    }
    
    func billboard(for ray: Ray) -> Billboard {
        let plane = ray.direction.orthogonal
        return Billboard(
            start: position - plane / 2,
            direction: plane, length: 1,
            texture: animation.texture
        )
    }
    
    func hitTest(_ ray: Ray) -> Vector? {
        guard isDead == false, let hit = billboard(for: ray).hitTest(ray) else {
            return nil
        }
        guard (hit - position).length < radius else {
            return nil
        }
        return hit
    }
}

public extension Animation {
    static let monsterIdle = Animation(frames: [
        .monster
    ], duration: 0)
    
    static let monsterBlocked = Animation(frames: [
        .monster
    ], duration: 1)
    
    static let monsterWalk = Animation(frames: [
        .monsterWalk1,
        .monster,
        .monsterWalk2,
        .monster
    ], duration: 0.5)
    
    static let monsterScratch = Animation(frames: [
        .monsterScratch1,
        .monsterScratch2,
        .monsterScratch3,
        .monsterScratch4,
        .monsterScratch5,
        .monsterScratch6,
        .monsterScratch7,
        .monsterScratch8
    ], duration: 0.8)
    
    static let monsterHurt = Animation(frames: [
        .monsterHurt
    ], duration: 0.2)
    
    static let monsterDeath = Animation(frames: [
        .monsterHurt,
        .monsterDeath1,
        .monsterDeath2
    ], duration: 0.5)
    
    static let monsterDead = Animation(frames: [
        .monsterDead
    ], duration: 0)
}
