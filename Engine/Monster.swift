//
//  Monster.swift
//  Engine
//
//  Created by Saulo Pratti on 08.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Monster: Actor {
    public var position: Vector
    public let radius: Double = 0.4375 // Equal to: 14 / 16 / 2
    
    public init(position: Vector) {
        self.position = position
    }
}

