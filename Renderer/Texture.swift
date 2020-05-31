//
//  Texture.swift
//  Engine
//
//  Created by Saulo Pratti on 07.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import Engine

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
        return textures[texture]!
    }
}
