//
//  MapGenerator.swift
//  Engine
//
//  Created by Saulo Pratti on 26.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct MapGenerator {
    public private(set) var map: Tilemap
    
    public init(mapData: MapData, index: Int) {
        self.map = Tilemap(mapData, index: index)
    }
}
