//
//  Game.swift
//  Engine
//
//  Created by Saulo Pratti on 24.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public protocol GameDelegate: AnyObject {
    func playSound(_ sound: Sound)
    func clearSounds()
}

public enum GameState {
    case title, playing
}

public struct Game {
    public weak var delegate: GameDelegate?
    public let levels: [Tilemap]
    public private(set) var world: World
    public private(set) var state: GameState = .title
    
    public init(levels: [Tilemap]) {
        self.levels = levels
        self.world = World(map: levels[0])
    }
}

public extension Game {
    mutating func update(timeStep: Double, input: Input) {
        guard let delegate = delegate else {
            return
        }
        
        // MARK: Update state
        switch state {
        case .title:
            if input.isFiring {
                state = .playing
            }
        case .playing:
            if let action = world.update(timeStep: timeStep, input: input) {
                switch action {
                case .loadLevel(let index):
                    let index = index % levels.count
                    world.setLevel(levels[index])
                    delegate.clearSounds()
                case .playSounds(let sounds):
                    sounds.forEach(delegate.playSound(_:))
                }
            }
        }
    }
}
