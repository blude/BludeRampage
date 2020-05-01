//
//  Color.swift
//  Engine
//
//  Created by Saulo Pratti on 29.04.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Color {
    public var r, g, b: UInt8
    public var a: UInt8 = 255
}

public extension Color {
    static let clear = Color(r: 0, g: 0, b: 0, a: 0)
    static let black = Color(r: 0, g: 0, b: 0)
    static let white = Color(r: 255, g: 255, b: 255)
    static let gray  = Color(r: 192, g: 192, b: 192)
    static let red   = Color(r: 255, g: 0, b: 0)
    static let green = Color(r: 0, g: 255, b: 0)
    static let blue  = Color(r: 0, g: 0, b: 255)
}
