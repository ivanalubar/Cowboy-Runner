//
//  GameplayScene.swift
//  Cowboy Runner
//
//  Created by Ivana Lubar on 10/03/2020.
//  Copyright © 2020 Ivana Lubar. All rights reserved.
//

import SpriteKit

class GameplayScene: SKScene, SKPhysicsContactDelegate {

    var player = Player()

    var obstacles = [SKSpriteNode]()

    var canJump = false

    var movePlayer = false

    var playerOnObstacle = false

    var isAlive = false

    var spawner = Timer()
    var counter = Timer()

    var scoreLabel = SKLabelNode()

    var score = Int(0)

    // Forts function that will be called when we run the game
    override func didMove(to view: SKView) {
        initialize()
    }

    override func update(_ currentTime: TimeInterval) {
        if isAlive {
            moveBackgroundsAndGrounds()
        }

        checkPlayerBounds()

        if movePlayer {
            position.x -= 9
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location).name == "Restart" {
                let gamePlay = GameplayScene(fileNamed: "GameplayScene")
                gamePlay?.scaleMode = .aspectFill
                self.view?.presentScene(gamePlay)
            }

            if atPoint(location).name == "Quit" {
                let mainMenu = MainMenuScene(fileNamed: "MainMenuScene")
                mainMenu?.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu)
            }

        }

        if canJump {
            canJump = false
            player.jump()
        }

        if playerOnObstacle {
            player.jump()
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {

        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground" {
            canJump = true
        }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {

            if !canJump {
                movePlayer = true
                playerOnObstacle = true
            }

        }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "Cactus" {
            playerDied()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        if contact.bodyA.node?.name == "Player" {
           firstBody = contact.bodyA
           secondBody = contact.bodyB
        } else {
           firstBody = contact.bodyB
           secondBody = contact.bodyA
        }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {

        movePlayer = false
        playerOnObstacle = false


        }
    }

    func initialize() {

        physicsWorld.contactDelegate = self

        isAlive = true

        createBG()
        createGrounds()
        createPlayer()
        createObstacles()
        getLabel()

        counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: Selector(("incrementScore")), userInfo: nil, repeats: true)

        spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 2.5, secondNumber: 6)), target: self, selector: Selector(("spawnObstacles")), userInfo: nil, repeats: true)

    }

    func createPlayer() {
        player = Player(imageNamed: "Player 1")
        player.initialize()
        player.position = CGPoint(x: -10, y: 20)
        self.addChild(player)
    }

    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            bg.zPosition = 0
            self.addChild(bg)
        }
    }

    func createGrounds() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "Ground")
            bg.name = "Ground"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -(self.frame.size.height / 2))
            bg.zPosition = 3
            bg.physicsBody = SKPhysicsBody(rectangleOf: bg.size)
            bg.physicsBody?.affectedByGravity = false
            bg.physicsBody?.isDynamic = false
            bg.physicsBody?.categoryBitMask = ColliderType.Ground
            self.addChild(bg)
       }
    }

    func moveBackgroundsAndGrounds() {
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in

            let bgNode = node as! SKSpriteNode

            bgNode.position.x -= 4

            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.frame.width * 3
            }
        }))

        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in

            let bgNode = node as! SKSpriteNode

            bgNode.position.x -= 4

            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.frame.width * 3
            }
        }))
    }

    func createObstacles() {

        for i in 0...5 {

            let obstacle = SKSpriteNode(imageNamed: "Obstacle \(i)")

            if i == 0 {
                obstacle.name = "Cactus"
                obstacle.setScale(0.4)
            } else {
                obstacle.name = "Obstacle"
                obstacle.setScale(0.5)
            }

            obstacle.anchorPoint = CGPoint(x: 0.5, y:0.5)
            obstacle.zPosition = 1

            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
            obstacle.physicsBody?.allowsRotation = false
            obstacle.physicsBody?.categoryBitMask = ColliderType.Obstacle

            obstacles.append(obstacle)

        }
    }

    @objc private func spawnObstacles() {

        let index = Int(arc4random_uniform(UInt32(obstacles.count)))

        let obstacle = obstacles[index].copy() as! SKSpriteNode

        obstacle.position = CGPoint(x: self.frame.width + obstacle.size.width, y: 50)

        let move = SKAction.moveTo(x: -(self.frame.width * 2), duration: TimeInterval(15))

        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([move, remove])

        obstacle.run(sequence)

        self.addChild(obstacle)
    }

    func randomBetweenNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {

        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }

    func checkPlayerBounds() {
        if isAlive {
            if player.position.x < -(self.frame.size.width / 2) - 35 {
            playerDied()
        }
        }
    }

    func playerDied() {

        let highscore = UserDefaults.standard.integer(forKey: "Highscore")
        if highscore < score {
            UserDefaults.standard.set(score ,forKey: "Highscore")
        }

        player.removeFromParent()

        for child in children {
            if child.name == "Obstacle" || child.name == "Cactus" {
                child.removeFromParent()
            }
        }

        spawner.invalidate()
        counter.invalidate()
        isAlive = false
        let restart = SKSpriteNode(imageNamed: "Restart")
        let quit = SKSpriteNode(imageNamed: "Quit")

        restart.name = "Restart"
        restart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        restart.position = CGPoint(x: -200, y: -150)
        restart.zPosition = 10
        restart.setScale(0)

        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 200, y: -150)
        quit.zPosition = 10
        quit.setScale(0)

        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval(0.5))

        restart.run(scaleUp)
        quit.run(scaleUp)

        self.addChild(restart)
        self.addChild(quit)
    }

    func getLabel() {
        scoreLabel = self.childNode(withName: "Score Label") as! SKLabelNode
        scoreLabel.text = "0M"
    }

    @objc private func incrementScore() {
        score += 1
        scoreLabel.text = "\(score)M"
    }
    
}
