//
//  Sounds.swift
//  Engine
//
//  Created by Saulo Pratti on 19.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum SoundName: String, CaseIterable {
    case pistolFire, ricochet
    case monsterHit, monsterGroan, monsterDeath, monsterSwipe
    case doorSlide, wallSlide, wallThud
    case switchFlip
    case playerDeath, playerWalk
    case squelch
    case medkit
    case shotgunFire, shotgunPickup
}

public struct Sound {
    public let name: SoundName?
    public let channel: Int?
    public let volume: Double
    public let pan: Double
    public let delay: Double
}
