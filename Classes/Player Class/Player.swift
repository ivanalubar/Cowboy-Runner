//
//  Player.swift
//  Cowboy Runner
//
//  Created by Ivana Lubar on 10/03/2020.
//  Copyright © 2020 Ivana Lubar. All rights reserved.
//

import SpriteKit

struct ColliderType {

    static let Player: UInt32 = 1
    static let Ground: UInt32 = 2
    static let Obstacle: UInt32 = 3

}

class Player: SKSpriteNode {

    func initialize() {

        var walk = [SKTexture]()
        for i in 1...11 {
           let name = "Player \(i)"
           walk.append(SKTexture(imageNamed: name))
        }

        let walkAnimation = SKAction.animate(with: walk, timePerFrame: TimeInterval(0.064), resize: true, restore: true)


        self.name = "Player"
        self.zPosition = 2
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setScale(0.5)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Obstacle
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Obstacle

        self.run(SKAction.repeatForever(walkAnimation))
    }

    func jump() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 350))
    }
}
