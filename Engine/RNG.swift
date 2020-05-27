//
//  RNG.swift
//  Engine
//
//  Created by Saulo Pratti on 27.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

private let multiplier: UInt64 = 6364136223846793005
private let increment: UInt64 = 1442695040888963407

public struct RNG {
    private var seed: UInt64 = 0
    
    public init(seed: UInt64) {
        self.seed = seed
    }
    
    public mutating func next() -> UInt64 {
        seed = seed &* multiplier &+ increment
        return seed
    }
}

public extension Collection where Index == Int {
    func randomElement(using generator: inout RNG) -> Element? {
        if isEmpty {
            return nil
        }
        return self[startIndex + Index(generator.next() % UInt64(count))]
    }
}
