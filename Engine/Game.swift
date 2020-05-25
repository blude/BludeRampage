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
    case title, starting, playing
}

public struct Game {
    public weak var delegate: GameDelegate?
    public let levels: [Tilemap]
    public let font: Font
    public var titleText = "TAP TO START"
    public private(set) var world: World
    public private(set) var state: GameState = .title
    public private(set) var transition: Effect?
    
    public init(levels: [Tilemap], font: Font) {
        self.levels = levels
        self.font = font
        self.world = World(map: levels[0])
    }
}

public extension Game {
    var hud: HUD {
        HUD(player: world.player, font: font)
    }
    
    mutating func update(timeStep: Double, input: Input) {
        guard let delegate = delegate else {
            return
        }
        
        // MARK: Update transitions
        if var effect = transition {
            effect.time += timeStep
            transition = effect
        }
        
        // MARK: Update state
        switch state {
        case .title:
            if input.isFiring {
                transition = Effect(type: .fadeOut, color: .black, duration: 0.5)
                state = .starting
            }
        case .starting:
            if transition?.isCompleted == true {
                transition = Effect(type: .fadeIn, color: .black, duration: 0.5)
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
