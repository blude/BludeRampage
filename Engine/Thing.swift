//
//  Thing.swift
//  Engine
//
//  Created by Saulo Pratti on 03.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Thing: String, Decodable {
    case nothing = " "
    case player = "@"
    case monster = "*"
    case door = "|"
    case pushwall = ">"
}
