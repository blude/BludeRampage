//
//  ViewController.swift
//  BludeRampage
//
//  Created by Saulo Pratti on 29.04.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import UIKit
import Engine
import Renderer

private let joystickRadius: Double = 40
private let maximumTimeStep: Double = 1 / 20
private let worldTimeStep: Double = 1 / 120

class ViewController: UIViewController {
    private let imageView = UIImageView()
    private let textures = loadTextures()
    private let panGesture = UIPanGestureRecognizer()
    private let tapGesture = UITapGestureRecognizer()
    private var game = Game(levels: loadLevels(), font: loadFont())
    private var lastFrameTime = CACurrentMediaTime()
    private var lastFiredTime = 0.0
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Stop execution if we're running tests
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        setUpAudio()
        setUpImageView()
        
        view.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        
        view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(fire))
        tapGesture.delegate = self
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .common)
        
        game.delegate = self
    }
    
    func setUpImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.layer.magnificationFilter = .nearest
    }

    @objc func update(_ displayLink: CADisplayLink) {
        let timeStep = min(maximumTimeStep, displayLink.timestamp - lastFrameTime)
        let width = Int(imageView.bounds.width)
        let height = Int(imageView.bounds.height)
        var renderer = Renderer(width: width, height: height, textures: textures)
        
        // MARK: Set screen safe area
        let insets = self.view.safeAreaInsets
        renderer.safeArea = Rect(
            min: Vector(x: Double(insets.left), y: Double(insets.top)),
            max: renderer.bitmap.size - Vector(x: Double(insets.left), y: Double(insets.bottom))
        )
        
        // MARK: Handle input and timing
        let inputVector = self.inputVector
        let rotation = inputVector.x * game.world.player.turningSpeed * worldTimeStep
        var input = Input(
            speed: -inputVector.y,
            rotation: Rotation(sine: sin(rotation), cosine: cos(rotation)),
            isFiring: lastFiredTime > lastFrameTime
        )
        lastFrameTime = displayLink.timestamp
        lastFiredTime = min(lastFiredTime, displayLink.timestamp)

        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            game.update(timeStep: timeStep / worldSteps, input: input)
            input.isFiring = false
        }
        
        // MARK: Render
        renderer.draw(game)
        imageView.image = UIImage(bitmap: renderer.bitmap)
    }
    
    @objc func fire(_ gestureRecognizer: UITapGestureRecognizer) {
        lastFiredTime = CACurrentMediaTime()
    }
    
    private var inputVector: Vector {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            var vector = Vector(x: Double(translation.x), y: Double(translation.y))
            vector /= max(joystickRadius, vector.length)
            panGesture.setTranslation(CGPoint(
                x: vector.x * joystickRadius,
                y: vector.y * joystickRadius
            ), in: view)
            return vector
        default:
            return Vector(x: 0, y: 0)
        }
    }

}

/// Load levels from a decoded json file and return a array of tilemap objects
public func loadLevels() -> [Tilemap] {
    let levels = Bundle.main.decode([MapData].self, from: "Levels.json")
    return levels.enumerated().map { index, mapData in
        return MapGenerator(mapData: mapData, index: index).map
    }
}

/// Load bitmap font from decoded json file
public func loadFont() -> Font {
    return Bundle.main.decode(Font.self, from: "Font.json")
}

public func loadTextures() -> Textures {
    return Textures { name in
        return Bitmap(image: UIImage(named: name)!)!
    }
}

/// Check if sound files are present and pre-warm cache for gapless playback
func setUpAudio() {
    for soundName in SoundName.allCases {
        precondition(soundName.url != nil, "Missing mp3 file for \(soundName.rawValue)")
    }
    try? SoundManager.shared.activate()
    _ = try? SoundManager.shared.preload(SoundName.allCases[0].url!)
}

public extension SoundName {
    var url: URL? {
        return Bundle.main.url(forResource: rawValue, withExtension: "mp3")
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

extension ViewController: GameDelegate {
    func playSound(_ sound: Sound) {
        DispatchQueue.main.asyncAfter(deadline: .now() + sound.delay) {
            guard let url = sound.name?.url else {
                if let channel = sound.channel {
                    SoundManager.shared.clearChannel(channel)
                }
                return
            }
            try? SoundManager.shared.play(url, channel: sound.channel, volume: sound.volume, pan: sound.pan)
        }
    }
    
    func clearSounds() {
        SoundManager.shared.clearAllChannels()
    }
}
