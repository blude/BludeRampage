//
//  Pickup.swift
//  Engine
//
//  Created by Saulo Pratti on 21.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum PickupType {
    case medkit, shotgun
}

public struct Pickup: Actor {
    public let type: PickupType
    public let radius: Double = 0.4
    public var position: Vector
    
    public init(type: PickupType, position: Vector) {
        self.type = type
        self.position = position
    }
}

public extension Pickup {
    var isDead: Bool { false }
    
    var texture: Texture {
        switch type {
        case .medkit:
            return .medkit
        case .shotgun:
            return .shotgunPickup
        }
    }
    
    func billboard(for ray: Ray) -> Billboard {
        let plane = ray.direction.orthogonal
        return Billboard(start: position - plane / 2, direction: plane, length: 1, texture: texture)
    }
}
