//
//  Billboard.swift
//  Engine
//
//  Created by Saulo Pratti on 08.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Billboard {
    public var start: Vector
    public var direction: Vector
    public var length: Double
    
    public init(start: Vector, direction: Vector, length: Double) {
        self.start = start
        self.direction = direction
        self.length = length
    }
}

public extension Billboard {
    var end: Vector {
        start + direction * length
    }
    
    func hitTest(_ ray: Ray) -> Vector? {
        var lhs = ray
        var rhs = Ray(origin: start, direction: direction)
        
        // Ensure rays are never exactly vertical
        let epsilon = 0.00001
        
        if abs(lhs.direction.x) < epsilon {
            lhs.direction.x = epsilon
        }
        
        if abs(rhs.direction.x) < epsilon {
            rhs.direction.x = epsilon
        }
        
        // Calculate slopes and intercepts
        let (slope1, intercept1) = lhs.slopeIntercept
        let (slope2, intercept2) = rhs.slopeIntercept
        
        // Check if slopes are parallel
        if slope1 == slope2 {
            return nil
        }
        
        // Find intersection point
        let x = (intercept1 - intercept2) / (slope2 - slope1)
        let y = slope1 * x + intercept1
        
        // Check if intersection point is in range
        let distanceAlongRay = (x - lhs.origin.x) / lhs.direction.x
        
        if distanceAlongRay < 0 {
            return nil
        }
        
        // Check that the intersection point lies between the start and end points of the sprite's billboard
        let distanceAlongBillboard = (x - rhs.origin.x) / rhs.direction.x
        
        if distanceAlongBillboard < 0 || distanceAlongBillboard > length {
            return nil
        }
        
        return Vector(x: x, y: y)
    }
}
