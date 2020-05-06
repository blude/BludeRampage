//
//  Ray.swift
//  Engine
//
//  Created by Saulo Pratti on 06.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Ray {
    public var origin, direction: Vector
    
    public init(origin: Vector, direction: Vector) {
        self.origin = origin
        self.direction = direction
    }
}
