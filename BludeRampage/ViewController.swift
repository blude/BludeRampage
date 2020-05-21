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
    private let levels = loadLevels()
    private lazy var world = World(map: levels[0])
    private var lastFrameTime = CACurrentMediaTime()
    private var lastFiredTime = 0.0

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

        let inputVector = self.inputVector
        let rotation = inputVector.x * world.player.turningSpeed * worldTimeStep
        let input = Input(
            speed: -inputVector.y,
            rotation: Rotation(sine: sin(rotation), cosine: cos(rotation)),
            isFiring: lastFiredTime > lastFrameTime
        )
        
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            if let action = world.update(timeStep: timeStep / worldSteps, input: input) {
                switch action {
                case .loadLevel(let index):
                    let index = index % levels.count
                    world.setLevel(levels[index])
                    SoundManager.shared.clearAllChannels()
                case .playSounds(let sounds):
                    for sound in sounds {
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
                }
            }
        }
        
        renderer.draw(world)
        
        lastFrameTime = displayLink.timestamp
        
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

public func loadLevels() -> [Tilemap] {
    let levels = Bundle.main.decode([MapData].self, from: "Levels.json")
    return levels.enumerated().map {
        Tilemap($0.element, index: $0.offset)
    }
}

public func loadTextures() -> Textures {
    Textures { name in
        Bitmap(image: UIImage(named: name)!)!
    }
}

func setUpAudio() {
    for soundName in SoundName.allCases {
        precondition(soundName.url != nil, "Missing mp3 file for \(soundName.rawValue)")
    }
    try? SoundManager.shared.activate()
    _ = try? SoundManager.shared.preload(SoundName.allCases[0].url!)
}

public extension SoundName {
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "mp3")
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
