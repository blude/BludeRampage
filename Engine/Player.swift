//
//  Player.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

/**
 We'll pass the Y component of the joystick `inputVector` as the speed, and use the X component to calculate the rotation.
 
 As you may recall from Part 2, the input velocity's magnitude ranges from 0 to 1, measured in world-units per second. On the engine side we multiply this by the player's maximum speed and the `timeStep` value before adding it to the position each frame.

 If we treat the X component as a rotational velocity value, it becomes radians per second rather than world units. This will also need to be multiplied by the time-step and a maximum turning speed, so let's add a `turningSpeed` property to `Player`:

 We've chosen a value of `pi` radians (180 degrees) for the turning speed, which means the player will be able to turn a full revolution in two seconds.

 Because we are fudging things a little by doing the trigonometry in the platform layer, we'll need to multiply the rotation by the `timeStep` and `turningSpeed` on the platform layer side instead of in `World.update()` as we did for the velocity. This is a bit inelegant, but still preferable to writing our own `sin` and `cos` functions.
 */

public enum PlayerState {
    case idle, firing
}

public struct Player: Actor {
    public let speed: Double = 2
    public let turningSpeed: Double = .pi
    public let radius: Double = 0.25
    public var position: Vector
    public var velocity: Vector
    public var direction: Vector
    public var health: Double
    public var state: PlayerState = .idle
    public var animation: Animation = .pistolIdle
    public let attackCooldown: Double = 0.25
    public let soundChannel: Int = 0
    
    public init(position: Vector) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
        self.direction = Vector(x: 1, y: 0)
        self.health = 100
    }
}

public extension Player {
    var isDead: Bool {
        health <= 0
    }
    
    var isMoving: Bool {
        velocity.x != 0 || velocity.y != 0
    }
    
    var canFire: Bool {
        switch state {
        case .idle:
            return true
        case .firing:
            return animation.time >= attackCooldown
        }
    }
    
    mutating func update(with input: Input, in world: inout World) {
        let wasMoving = isMoving
        
        direction = direction.rotated(by: input.rotation)
        velocity = direction * input.speed * speed
        
        if input.isFiring, canFire {
            state = .firing
            animation = .pistolFire
            let ray = Ray(origin: position, direction: direction)
            
            if let index = world.pickMonster(ray) {
                world.hurtMonster(at: index, damage: 10)
                world.playSound(.monsterHit, at: world.monsters[index].position)
            } else {
                let hitPosition = world.hitTest(ray)
                world.playSound(.ricochet, at: hitPosition)
            }
        }
        
        switch state {
        case .idle:
            break
        case .firing:
            if animation.isCompleted {
                state = .idle
                animation = .pistolIdle
                world.playSound(.pistolFire, at: position)
            }
        }
        
        if isMoving, !wasMoving {
            world.playSound(.playerWalk, at: position, in: soundChannel)
        } else if !isMoving {
            world.playSound(nil, at: position, in: soundChannel)
        }
    }
}
    
public extension Animation {
    static let pistolIdle = Animation(frames: [
        .pistol
    ], duration: 0)

    static let pistolFire = Animation(frames: [
        .pistolFire1,
        .pistolFire2,
        .pistolFire3,
        .pistolFire4,
        .pistol
    ], duration: 0.5)
}
