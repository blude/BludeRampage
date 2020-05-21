//
//  Weapon.swift
//  Engine
//
//  Created by Saulo Pratti on 21.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Weapon {
    case pistol, shotgun
}

public extension Weapon {
    struct Attributes {
        let idleAnimation: Animation
        let fireAnimation: Animation
        let fireSound: SoundName
    }
    
    var attributes: Attributes {
        switch self {
        case .pistol:
            return Attributes(idleAnimation: .pistolIdle, fireAnimation: .pistolFire, fireSound: .pistolFire)
        case .shotgun:
            return Attributes(idleAnimation: .shotgunIdle, fireAnimation: .shotgunFire, fireSound: .shotgunFire)
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
    
    static let shotgunIdle = Animation(frames: [
        .shotgun
    ], duration: 0)
    
    static let shotgunFire = Animation(frames: [
        .shotgunFire1,
        .shotgunFire2,
        .shotgunFire3,
        .shotgunFire4,
        .shotgun
    ], duration: 0.5)
}