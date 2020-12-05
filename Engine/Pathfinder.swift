//
//  Pathfinder.swift
//  Engine
//
//  Created by Saulo Pratti on 23.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

public protocol Graph {
    associatedtype Node: Hashable
    
    /// Return a list of connected nodes
    /// - Parameter node: desired node
    func nodesConnectedTo(_ node: Node) -> [Node]
    
    /// Return the estimated distance between two nodes in the game.
    /// - Parameters:
    ///   - a: first node
    ///   - b: second node
    func estimateDistance(from a: Node, to b: Node) -> Double
    
    /// Return the number of steps between two different nodes.
    /// - Parameters:
    ///   - a: first node
    ///   - b: second node
    func stepDistance(from a: Node, to b: Node) -> Double
}

/// A path is used to describe a collection of `Node` points in the game.
private class Path<Node> {
    let head: Node
    let tail: Path?
    let distanceTravelled: Double
    let totalDistance: Double
    
    /// Create a `Path` instance
    /// - Parameters:
    ///   - head: the first item of the linked-list
    ///   - tail: the remaining part of the list
    ///   - stepDistance: the distance between nodes
    ///   - remaining: remaining steps
    init(head: Node, tail: Path?, stepDistance: Double, remaining: Double) {
        self.head = head
        self.tail = tail
        self.distanceTravelled = (tail?.distanceTravelled ?? 0) + stepDistance
        self.totalDistance = distanceTravelled + remaining
    }
    
    /// List of nodes in the current `Path`.
    var nodes: [Node] {
        var nodes = [head]
        var tail = self.tail
        
        while let path = tail {
            nodes.insert(path.head, at: 0)
            tail = path.tail
        }
        
        nodes.removeFirst()
        return nodes
    }
}

public extension Graph {
    func findPath(from start: Node, to end: Node, maxDistance: Double) -> [Node] {
        var visited = Set([start])
        var paths = [Path(
            head: start,
            tail: nil,
            stepDistance: 0,
            remaining: estimateDistance(from: start, to: end)
        )]
        
        while let path = paths.popLast() {
            // Finish if goal reached
            if path.head == end {
                return path.nodes
            }
            
            // Get connected nodes
            for node in nodesConnectedTo(path.head) where !visited.contains(node) {
                visited.insert(node)
                
                let next = Path(
                    head: node,
                    tail: path,
                    stepDistance: stepDistance(from: path.head, to: node),
                    remaining: estimateDistance(from: node, to: end)
                )
                
                // Skip this node if max distance exceeded
                if next.totalDistance > maxDistance {
                    break
                }
                
                // Insert shortest path last
                if let index = paths.firstIndex(where: {
                    $0.totalDistance <= next.totalDistance
                }) {
                    paths.insert(next, at: index)
                } else {
                    paths.append(next)
                }
            }

        }
        
        // Unreacheable
        return []
    }
}
