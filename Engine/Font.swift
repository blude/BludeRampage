//
//  Font.swift
//  Engine
//
//  Created by Saulo Pratti on 25.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Font: Decodable {
    public let texture: Texture
    public let characters: [String]
}
