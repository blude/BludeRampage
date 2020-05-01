//
//  Player.swift
//  Engine
//
//  Created by Saulo Pratti on 02.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Player {
    public var position: Vector
    public var velocity: Vector
    
    public init(position: Vector) {
        self.position = position
        self.velocity = Vector(x: 1, y: 1)
    }
}

public extension Player {
    mutating func update(timeStep: Double) {
        position += velocity * timeStep
        position.x.formTruncatingRemainder(dividingBy: 8)
        position.y.formTruncatingRemainder(dividingBy: 8)
    }
}
