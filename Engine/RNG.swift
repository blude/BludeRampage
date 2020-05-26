//
//  RNG.swift
//  Engine
//
//  Created by Saulo Pratti on 27.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

private let multiplier: UInt64 = 6364136223846793005
private let increment: UInt64 = 1442695040888963407

public struct RNG: RandomNumberGenerator {
    private var seed: UInt64 = 0
    
    public init(seed: UInt64) {
        self.seed = seed
    }
    
    public mutating func next() -> UInt64 {
        seed = seed &* multiplier &+ increment
        return seed
    }
}
