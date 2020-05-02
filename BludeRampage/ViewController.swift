//
//  ViewController.swift
//  BludeRampage
//
//  Created by Saulo Pratti on 29.04.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import UIKit
import Engine

private let joystickRadius: Double = 40

class ViewController: UIViewController {
    private let imageView = UIImageView()
    private let panGesture = UIPanGestureRecognizer()
    private var world = World(map: loadMap())
    private var lastTimeFrame = CACurrentMediaTime()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
        
        view.addGestureRecognizer(panGesture)
        
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
        let timeStep = displayLink.timestamp - lastTimeFrame
        let bitmapSize = Int(min(imageView.bounds.width, imageView.bounds.height))
        let input = Input(velocity: inputVector)
        var renderer = Renderer(width: bitmapSize, height: bitmapSize)

        world.update(timeStep: timeStep, input: input)
        renderer.draw(world)
        
        lastTimeFrame = displayLink.timestamp
        
        imageView.image = UIImage(bitmap: renderer.bitmap)
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

func loadMap() -> Tilemap {
    let jsonURL = Bundle.main.url(forResource: "Map.json", withExtension: nil)!
    let jsonData = try! Data(contentsOf: jsonURL)
    return try! JSONDecoder().decode(Tilemap.self, from: jsonData)
}

