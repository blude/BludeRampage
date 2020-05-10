//
//  Effect.swift
//  Engine
//
//  Created by Saulo Pratti on 10.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum EffectType {
    case fadeIn, fadeOut
}

public struct Effect {
    public let type: EffectType
    public let color: Color
    public let duration: Double
    public var time: Double = 0
    
    public init(type: EffectType, color: Color, duration: Double) {
        self.type = type
        self.color = color
        self.duration = duration
    }
}

public extension Effect {
    var isCompleted: Bool {
        time >= duration
    }
    
    var progress: Double {
        min(1, time / duration)
    }
}
