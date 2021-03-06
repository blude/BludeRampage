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
    public private(set) var weapon: Weapon = .pistol
    public private(set) var ammo: Double
    public var animation: Animation
    public let soundChannel: Int
    
    public init(position: Vector, soundChannel: Int) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
        self.direction = Vector(x: 1, y: 0)
        self.health = 100
        self.soundChannel = soundChannel
        self.animation = weapon.attributes.idleAnimation
        self.ammo = weapon.attributes.defaultAmmo
    }
}

public extension Player {
    var isDead: Bool {
        return health <= 0
    }
    
    var isMoving: Bool {
        return velocity.x != 0 || velocity.y != 0
    }
    
    var canFire: Bool {
        guard ammo > 0 else {
            return false
        }

        switch state {
        case .idle:
            return true
        case .firing:
            return animation.time >= weapon.attributes.cooldown
        }
    }
    
    /// Set the player's weapon
    /// - Parameter weapon: one of the available weapons
    mutating func setWeapon(_ weapon: Weapon) {
        self.weapon = weapon
        self.animation = weapon.attributes.idleAnimation
        self.ammo = weapon.attributes.defaultAmmo
    }
    
    /// Gives the player the ability to inherit properties across different game levels
    /// - Parameter player: the player instance
    mutating func inherit(from player: Player) {
        health = player.health
        setWeapon(player.weapon)
        ammo = player.ammo
    }
    
    /// Update the player instance based on live input and acting in the world
    /// - Parameters:
    ///   - input: input passed by virtual game controllers
    ///   - world: world environment
    mutating func update(with input: Input, in world: inout World) {
        let wasMoving = isMoving
        
        direction = direction.rotated(by: input.rotation)
        velocity = direction * input.speed * speed
        
        if input.isFiring, canFire {
            state = .firing
            ammo -= 1
            animation = weapon.attributes.fireAnimation
            
            world.playSound(weapon.attributes.fireSound, at: position)
            
            let projectiles = weapon.attributes.projectiles
            var hitPosition, missPosition: Vector?
            
            for _ in 0 ..< projectiles {
                let spread = weapon.attributes.spread
                let sine = Double.random(in: -spread ... spread)
                let cosine = (1 - sine * sine).squareRoot()
                let rotation = Rotation(sine: sine, cosine: cosine)
                let direction = self.direction.rotated(by: rotation)
                let ray = Ray(origin: position, direction: direction)
                
                if let index = world.pickMonster(ray) {
                    let damage = weapon.attributes.damage / Double(projectiles)
                    world.hurtMonster(at: index, damage: damage)
                    hitPosition = world.monsters[index].position
                } else {
                    missPosition = world.hitTest(ray)
                }
            }

            if let hitPosition = hitPosition {
                world.playSound(.monsterHit, at: hitPosition)
            }
            
            if let missPosition = missPosition {
                world.playSound(.ricochet, at: missPosition)
            }
            
        }
        
        switch state {
        case .idle:
            if ammo == 0 {
                setWeapon(.pistol)
            }
        case .firing:
            if animation.isCompleted {
                state = .idle
                animation = weapon.attributes.idleAnimation
            }
        }
        
        if isMoving, !wasMoving {
            world.playSound(.playerWalk, at: position, in: soundChannel)
        } else if !isMoving {
            world.playSound(nil, at: position, in: soundChannel)
        }
    }
}

