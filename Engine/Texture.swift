//
//  Texture.swift
//  Engine
//
//  Created by Saulo Pratti on 07.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum Texture: String, CaseIterable {
    case wall, wall2
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
