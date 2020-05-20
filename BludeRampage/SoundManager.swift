//
//  SoundManager.swift
//  BludeRampage
//
//  Created by Saulo Pratti on 20.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import AVFoundation

public class SoundManager: NSObject, AVAudioPlayerDelegate {
    private var playing: Set<AVAudioPlayer> = []
    public static let shared: SoundManager = .init()
    
    private override init() {
        
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing.remove(player)
    }
}

public extension SoundManager {
    func activate() throws {
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    func preload(_ url: URL) throws -> AVAudioPlayer {
        try AVAudioPlayer(contentsOf: url)
    }
    
    func play(_ url: URL, volume: Double) throws {
        let player = try AVAudioPlayer(contentsOf: url)
        playing.insert(player)
        player.delegate = self
        player.volume = Float(volume)
        player.play()
    }
}
