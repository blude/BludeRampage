//
//  Thing.swift
//  Engine
//
//  Created by Saulo Pratti on 03.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Thing: String, Decodable {
    case nothing = " " // 0
    case player = "@" // 1
    case monster = "*" // 2
    case door = "|" // 3
    case pushwall = "<" // 4
    case `switch` = "l" // 5
}
