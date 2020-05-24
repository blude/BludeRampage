//
//  Renderer.swift
//  Engine
//
//  Created by Saulo Pratti on 29.04.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import Engine

private let fizzle = (0 ..< 10000).shuffled()

public struct Renderer {
    public private(set) var bitmap: Bitmap
    private let textures: Textures
    
    public init(width: Int, height: Int, textures: Textures) {
        self.bitmap = Bitmap(width: width, height: height, color: .black)
        self.textures = textures
    }
}

public extension Renderer {
    mutating func draw(_ world: World) {
        /**
         The length of the line represents the view width in world units. This has no direct relationship
         to how many pixels wide the view is on-screen, it's more about how big we want the world to appear
         from the player's viewpoint.
         
         Since the player's direction vector is normalized (has a length of 1) the orthogonal vector will
         be as well. That means we can just multiply the orthogonal vector by the view width to get a line
         of the correct length to represent the view plane.
         
         `let viewPlane = world.player.direction.orthogonal * viewWidth`

         The distance of the view plane from the player is the focal length. This affects how near things
         appear to be. Together, the view width and focal length define the Field of View (FoV), which
         determines how much of the world the player can see at once.
         
         We'll set both the view width and the focal length to `1.0` for now. This gives a FoV angle of ~53
         degrees[1], which is a little narrow, but we'll fix that later. Add the following code to the end
         of the `Renderer.draw()` method:
         */
        
        let focalLength = 1.0
        let viewWidth = Double(bitmap.width) / Double(bitmap.height)
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2
        
        /**
         To get the direction of each ray, we subtract the player position from the current column
         position along the view plane.
         
         The length of `rayDirection` is the diagonal distance from the player to the view plane. We mentioned
         earlier that direction vectors should always be normalized, and while it doesn't matter right now,
         it will help us avoid some weird bugs later. To normalize the ray direction, we divide it by its length.
         
         Finally, we need to compute the ray intersection point and draw the ray (as before), then increment the
         column position by adding the step to it.
         */
        
        // MARK: Cast rays
        let epsilon = 0.0001
        let columns = bitmap.width
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart
        
        for x in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)
            let end = world.map.hitTest(ray)
            let wallDistance = (end - ray.origin).length
            
            // MARK: Draw wall
            let wallHeight = 1.0
            let distanceRatio = viewPlaneDistance / focalLength
            let perpendicular = wallDistance / distanceRatio
            let height = wallHeight * focalLength / perpendicular * Double(bitmap.height)

            // Set up texture drawing
            let wallTexture: Bitmap
            let wallX: Double
            let (tileX, tileY) = world.map.tileCoords(at: end, from: ray.direction)
            let tile = world.map[tileX, tileY]
            
            // Check the walls orientation
            if end.x.rounded(.down) == end.x {
                let neighborX = tileX + (ray.direction.x > 0 ? -1: 1)
                let isDoor = world.isDoor(at: neighborX, tileY)
                wallTexture = textures[isDoor ? .doorjamb : tile.textures[0]]
                wallX = end.y - end.y.rounded(.down)
            } else {
                let neighborY = tileY + (ray.direction.y > 0 ? -1 : 1)
                let isDoor = world.isDoor(at: tileX, neighborY)
                wallTexture = textures[isDoor ? .doorjamb2 : tile.textures[1]]
                wallX = end.x - end.x.rounded(.down)
            }
            
            let textureX = Int(wallX * Double(wallTexture.width))
            let wallStart = Vector(x: Double(x), y: (Double(bitmap.height) - height) / 2 - epsilon)
            
            bitmap.drawColumn(textureX, of: wallTexture, at: wallStart, height: height)
            
            // MARK: Draw floor and ceiling
            var floorTile: Tile!
            var floorTexture, ceilingTexture: Bitmap!
            let floorStart = Int(wallStart.y + height) + 1
            
            for y in min(floorStart, bitmap.height) ..< bitmap.height {
                let normalizedY = (Double(y) / Double(bitmap.height)) * 2 - 1
                let perpendicular = wallHeight * focalLength / normalizedY
                let distance = perpendicular * distanceRatio
                let mapPosition = ray.origin + ray.direction * distance
                let tileX = mapPosition.x.rounded(.down)
                let tileY = mapPosition.y.rounded(.down)
                let tile = world.map[Int(tileX), Int(tileY)]
                
                if tile != floorTile {
                    floorTexture = textures[tile.textures[0]]
                    ceilingTexture = textures[tile.textures[1]]
                    floorTile = tile
                }
                
                let textureX = mapPosition.x - tileX
                let textureY = mapPosition.y - tileY
                
                // Draw the floor
                bitmap[x, y] = floorTexture[normalized: textureX, textureY]
                
                // Draw the ceiling
                bitmap[x, bitmap.height - 1 - y] = ceilingTexture[normalized: textureX, textureY]
            }
            
            // MARK: Draw switch
            if let s = world.switch(at: tileX, tileY) {
                let switchTexture = textures[s.animation.texture]
                bitmap.drawColumn(textureX, of: switchTexture, at: wallStart, height: height)
            }
            
            // MARK: Sort sprites by distance
            var spritesByDistance: [(hit: Vector, distance: Double, sprite: Billboard)] = []
            for sprite in world.sprites {
                guard let hit = sprite.hitTest(ray) else  {
                    continue
                }
                let spriteDistance = (hit - ray.origin).length
                if spriteDistance > wallDistance {
                    continue
                }
                spritesByDistance.append((hit: hit, distance: spriteDistance, sprite: sprite))
            }
            spritesByDistance.sort { $0.distance > $1.distance }
            
            // MARK: Draw sprites
            for (hit, spriteDistance, sprite) in spritesByDistance {
                let perpendicular = spriteDistance / distanceRatio
                let height = wallHeight / perpendicular * Double(bitmap.height)
                let spriteX = (hit - sprite.start).length / sprite.length
                let spriteTexture = textures[sprite.texture]
                let textureX = min(Int(spriteX * Double(spriteTexture.width)), spriteTexture.width - 1)
                let start = Vector(x: Double(x), y: (Double(bitmap.height) - height) / 2 + epsilon)
                
                bitmap.drawColumn(textureX, of: spriteTexture, at: start, height: height)
            }
            
            columnPosition += step
        }
        
        // MARK: Player weapon
        let weaponTexture = textures[world.player.animation.texture]
        let weaponScale = bitmap.size.y / weaponTexture.size.y
        let weaponSize = weaponTexture.size * weaponScale
        bitmap.drawImage(weaponTexture, at: (bitmap.size - weaponSize) / 2, size: weaponSize)
        
        // MARK: Crosshair
        let crosshair = textures[.crosshair]
        let hudScale = bitmap.size.y / 64
        let crosshairSize = crosshair.size * hudScale
        bitmap.drawImage(crosshair, at: (bitmap.size - crosshairSize) / 2, size: crosshairSize)
        
        // MARK: Health
        let font = textures[.font]
        let charSize = Vector(x: font.size.x / 10, y: font.size.y)
        let healthIcon = textures[.healthIcon]
        var offset = Vector(x: 1, y: 1) * hudScale
        bitmap.drawImage(healthIcon, at: offset, size: healthIcon.size * hudScale)
        offset.x += healthIcon.size.x * hudScale
        
        let rangeOfX = 0 ..< Int(charSize.x)
        bitmap.drawImage(font, rangeOfX: rangeOfX, at: offset, size: charSize * hudScale)
        
        // MARK: Effects
        for effect in world.effects {
            switch effect.type {
            case .fadeIn:
                bitmap.tint(with: effect.color, opacity: 1 - effect.progress)
            case .fadeOut:
                bitmap.tint(with: effect.color, opacity: effect.progress)
            case .fizzleOut:
                let threshold = Int(effect.progress * Double(fizzle.count))
                for x in 0 ..< bitmap.width {
                    for y in 0 ..< bitmap.height {
                        let granularity = 4
                        let index = y / granularity * bitmap.width + x / granularity
                        let fizzledIndex = fizzle[index % fizzle.count]
                        if fizzledIndex <= threshold {
                            bitmap[x, y] = effect.color
                        }
                    }
                }
            }
        }
    }
}
