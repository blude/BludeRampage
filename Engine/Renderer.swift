//
//  Renderer.swift
//  Engine
//
//  Created by Saulo Pratti on 29.04.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public struct Renderer {
    public private(set) var bitmap: Bitmap
    
    public init(width: Int, height: Int) {
        self.bitmap = Bitmap(width: width, height: height, color: .black)
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
        let viewWidth = 1.0
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
        
        // Cast rays
        let columns = bitmap.width
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart
        
        for x in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)
            let end = world.map.hitTest(ray)
            let wallDistance = (end - ray.origin).length
            
            // Draw wall
            let wallHeight = 1.0
            let height = wallHeight * focalLength / wallDistance * Double(bitmap.height)
            let wallColor: Color
            
            /**
             Early 3D games tended to use very simple lighting systems, as true, dynamic lights were too expensive.
             Wolfenstein actually had no lighting at all, it just used darker wall textures for North/South facing
             walls to add contrast.

             We don't have textures yet, but we can replicate Wolfenstein's approach by simply using two color
             tones. We know that walls are aligned on a 1x1 grid, so a wall coordinate with an exact integer Y
             value must be a North/South facing.
             */
            
            if end.x.rounded(.down) == end.x {
                wallColor = .white
            } else {
                wallColor = .gray
            }
            
            bitmap.drawLine(
                from: Vector(x: Double(x), y: (Double(bitmap.height) - height) / 2),
                to: Vector(x: Double(x), y: (Double(bitmap.height) + height) / 2),
                color: wallColor
            )
            
            columnPosition += step
        }
        
    }
}
