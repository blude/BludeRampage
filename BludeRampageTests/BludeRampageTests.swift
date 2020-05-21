//
//  BludeRampageTests.swift
//  BludeRampageTests
//
//  Created by Saulo Pratti on 12.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import XCTest
import Engine
import BludeRampage

class BludeRampageTests: XCTestCase {
    let world = World(map: loadLevels()[0])
    let textures = loadTextures()
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testRenderFrame() {
        measure {
            var renderer = Renderer(width: 1000, height: 1000, textures: textures)
            renderer.draw(world)
        }
    }

}
