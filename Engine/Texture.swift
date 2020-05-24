//
//  Texture.swift
//  Engine
//
//  Created by Saulo Pratti on 21.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Texture: String, CaseIterable {
    case wall, wall2
    case crackWall, crackWall2
    case slimeWall, slimeWall2
    case floor, crackFloor
    case door, door2
    case doorjamb, doorjamb2
    case ceiling
    case elevatorFloor, elevatorCeiling, elevatorSideWall, elevatorBackWall
    case switch1, switch2, switch3, switch4
    case monster, monsterWalk1, monsterWalk2
    case monsterHurt, monsterDeath1, monsterDeath2, monsterDead
    case monsterScratch1, monsterScratch2, monsterScratch3, monsterScratch4,
        monsterScratch5, monsterScratch6, monsterScratch7, monsterScratch8
    case pistol, pistolFire1, pistolFire2, pistolFire3, pistolFire4
    case shotgun, shotgunFire1, shotgunFire2, shotgunFire3, shotgunFire4
    case medkit, shotgunPickup
    case crosshair, healthIcon, font
}
