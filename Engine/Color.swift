//
//  Color.swift
//  Engine
//
//  Created by Saulo Pratti on 29.04.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Color {
    public var r, g, b, a: UInt8
    
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

public extension Color {
    var isOpaque: Bool {
        return a == 255
    }
    
    static let clear = Color(r: 0, g: 0, b: 0, a: 0)
    static let black = Color(r: 0, g: 0, b: 0)
    static let white = Color(r: 255, g: 255, b: 255)
    
    static let gray  = Color(r: 192, g: 192, b: 192)
    static let red   = Color(r: 217, g: 87, b: 99)
    static let green = Color(r: 153, g: 229, b: 80)
    static let blue  = Color(r: 0, g: 0, b: 255)
    static let yellow = Color(r: 251, g: 242, b: 54)

    mutating func tint(with color: Color) {
        self.r = UInt8(UInt16(self.r) * UInt16(color.r) / 255)
        self.g = UInt8(UInt16(self.g) * UInt16(color.g) / 255)
        self.b = UInt8(UInt16(self.b) * UInt16(color.b) / 255)
        self.a = UInt8(UInt16(self.a) * UInt16(color.a) / 255)
    }
}
