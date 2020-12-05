//
//  Vector.swift
//  Engine
//
//  Created by Saulo Pratti on 01.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Vector: Hashable {
    public var x, y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public extension Vector {
    var length: Double {
        return (x * x + y * y).squareRoot()
    }
    
    /// Return the dot product of vector multiplication
    /// - Parameter rhs: the right-hand side argument of the multiplication
    func dot(_ rhs: Vector) -> Double {
        return x * rhs.x + y * rhs.y
    }
    
    /**
     Since our world is two-dimensional, we can think of the view plane as a line rather than a rectangle.
     The direction of this line is always orthogonal to the direction that the camera is facing.
     The orthogonal vector can be computed as (-Y, X).
    */
    var orthogonal: Vector {
        return Vector(x: -y, y: x)
    }
    
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: Vector, rhs: Double) -> Vector {
        return Vector(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func / (lhs: Vector, rhs: Double) -> Vector {
        return Vector(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func * (lhs: Double, rhs: Vector) -> Vector {
        return Vector(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func / (lhs: Double, rhs: Vector) -> Vector {
        return Vector(x: lhs / rhs.x, y: lhs / rhs.y)
    }
    
    static func += (lhs: inout Vector, rhs: Vector) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    static func -= (lhs: inout Vector, rhs: Vector) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
    static func *= (lhs: inout Vector, rhs: Double) {
        lhs.x *= rhs
        lhs.y *= rhs
    }
    
    static func /= (lhs: inout Vector, rhs: Double) {
        lhs.x /= rhs
        lhs.y /= rhs
    }
    
    static prefix func - (rhs: Vector) -> Vector {
        return Vector(x: -rhs.x, y: -rhs.y)
    }
}
