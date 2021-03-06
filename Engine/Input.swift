//
//  Input.swift
//  Engine
//
//  Created by Saulo Pratti on 03.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Input {
    public var speed: Double
    public var rotation: Rotation
    public var isFiring: Bool
    
    public init(speed: Double, rotation: Rotation, isFiring: Bool) {
        self.speed = speed
        self.rotation = rotation
        self.isFiring = isFiring
    }
}
