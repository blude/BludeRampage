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
    
    public init(position: Vector, isVertical: Bool) {
        self.position = position
        if isVertical {
            self.direction = Vector(x: 0, y: 1)
            self.texture = .door
        } else {
            self.direction = Vector(x: 1, y: 0)
            self.texture = .door2
        }
    }
}

public extension Door {
    var rect: Rect {
        let position = self.position - direction * 0.5
        return Rect(min: position, max: position + direction)
    }
    
    var billboard: Billboard {
        Billboard(
            start: position - direction * 0.5,
            direction: direction,
            length: 1,
            texture: texture
        )
    }
    
    func hitTest(_ ray: Ray) -> Vector? {
        billboard.hitTest(ray)
    }
}
