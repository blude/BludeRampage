//
//  Texture.swift
//  Engine
//
//  Created by Saulo Pratti on 07.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Texture: String, CaseIterable {
    case wall, crackWall, slimeWall
    case wall2, crackWall2, slimeWall2
    case floor, crackFloor
    case ceiling
    case monster, monsterWalk1, monsterWalk2
    case monsterScratch1, monsterScratch2, monsterScratch3, monsterScratch4,
        monsterScratch5, monsterScratch6, monsterScratch7, monsterScratch8
    case pistol
}

public struct Textures {
    private let textures: [Texture: Bitmap]
}

public extension Textures {
    init(loader: (String) -> Bitmap) {
        var textures = [Texture: Bitmap]()
        
        for texture in Texture.allCases {
            textures[texture] = loader(texture.rawValue)
        }
        
        self.init(textures: textures)
    }
    
    subscript(_ texture: Texture) -> Bitmap {
        textures[texture]!
    }
}
