//
//  Game.swift
//  Engine
//
//  Created by Saulo Pratti on 24.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public enum GameState {
    case title, playing
}

public struct Game {
    public let levels: [Tilemap]
    public private(set) var world: World
    public private(set) var state: GameState = .title
    
    public init(levels: [Tilemap]) {
        self.levels = levels
        self.world = World(map: levels[0])
    }
}
