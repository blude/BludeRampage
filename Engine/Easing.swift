//
//  Easing.swift
//  Engine
//
//  Created by Saulo Pratti on 11.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Easing {}

public extension Easing {
    static func linear(_ t: Double) -> Double {
        t
    }
    
    static func easeIn(_ t: Double) -> Double {
        t * t
    }
    
    static func easeOut(_ t: Double) -> Double {
        1 - easeIn(1 - t)
    }
    
    static func easeInEaseOut(_ t: Double) -> Double {
        if t < 0.5 {
            return 2 * easeIn(t)
        } else {
            return 4 * t - 2 * easeIn(t) - 1
        }
    }
    
}
