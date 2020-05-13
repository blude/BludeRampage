//
//  Door.swift
//  Engine
//
//  Created by Saulo Pratti on 13.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Door {
    public let position: Vector
    public let direction: Vector
    public let texture: Texture
    
    public init(position: Vector, direction: Vector, texture: Texture) {
        self.position = position
        self.direction = direction
        self.texture = texture
    }
}

public extension Door {
    var billboard: Billboard {
        Billboard(
            start: position - direction * 0.5,
            direction: direction,
            length: 1,
            texture: texture
        )
    }
}
