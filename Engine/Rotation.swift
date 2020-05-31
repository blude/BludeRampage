//
//  Rotation.swift
//  Engine
//
//  Created by Saulo Pratti on 06.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Rotation {
    var m1, m2, m3, m4: Double
}

/**
 A 2x2 matrix contains 4 numbers, hence the four parameters. The `m[x]` naming is conventional, but unless you
 are well-versed with linear algebra those parameters won't mean a whole lot. Let's add an initializer with
 slightly more ergonomic parameters:
 
 This initializer takes the sine and cosine of a given angle and produces a matrix representing a rotation
 by that angle. We already said that we can't (easily) use the `sin` and `cos` functions inside the engine itself,
 but that's OK because we'll we be doing that part in the platform layer.
 */

public extension Rotation {
    init(sine: Double, cosine: Double) {
        self.init(m1: cosine, m2: -sine, m3: sine, m4: cosine)
    }
}

/**
 Finally, we'll add a function to apply the rotation to a vector. This feels most natural to write as an
 extension method on `Vector` itself, but we'll put that extension in the `Rotation.swift` file because it makes
 more sense from a grouping perspective.
 */

public extension Vector {
    func rotated(by rotation: Rotation) -> Vector {
        return Vector(
            x: x * rotation.m1 + y * rotation.m2,
            y: x * rotation.m3 + y * rotation.m4
        )
    }
}
