//
//  MainScene.swift
//  homework3
//
//  Created by Jeffery Ho on 2020/4/22.
//  Copyright © 2020 Jeffery Ho. All rights reserved.
//

import UIKit
import SpriteKit

class MainScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var scoreValue: Int = 0
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        createScene()
        let panrecognizer = UIPanGestureRecognizer(target: self, action: #selector(handpan))
        view.addGestureRecognizer(panrecognizer)
    }
    
    func createScene() {
        let mainBg = SKSpriteNode(imageNamed: "mainbgd.png")
        mainBg.size.width = self.size.width
        mainBg.size.height = self.size.height
        mainBg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mainBg.zPosition = -1
        
        let spaceShip = newSpaceShip(position: CGPoint(x: self.frame.midX, y: self.frame.midY))
        
        scoreLabel = SKLabelNode(text: "Score: \(scoreValue)")
        scoreLabel.name = "scoreLabel"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 100)
        scoreLabel.fontName = "Avenir-Oblique"
        scoreLabel.fontSize = 20
        
        self.addChild(mainBg)
        self.addChild(spaceShip)
        self.addChild(scoreLabel)
        
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(newRock), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(newCoin), userInfo: nil, repeats: true)
    }
    
    func newSpaceShip(position: CGPoint) -> SKSpriteNode {
        let ship = SKSpriteNode(imageNamed: "spaceship.png")
        ship.size = CGSize(width: 75, height: 75)
        ship.name = "ships"
        ship.position = position
        
        ship.addChild(newLight(position: CGPoint(x: -20, y: 6)))
        ship.addChild(newLight(position: CGPoint(x: 20, y: 6)))
        
        ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width / 2)
        ship.physicsBody?.usesPreciseCollisionDetection = true
        ship.physicsBody?.isDynamic = false
        ship.physicsBody?.categoryBitMask = 0x1 << 1
        ship.physicsBody?.contactTestBitMask = 0x1 << 2
        
        return ship
    }
    
    func newLight(position: CGPoint) -> SKShapeNode {
        let light = SKShapeNode()
        light.path = CGPath(rect: CGRect(x: -2, y: -4, width: 4, height: 8), transform: nil)
        light.strokeColor = SKColor.white
        light.fillColor = SKColor.yellow
        light.position = position
        
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)
        ])
        
        let blinkForever = SKAction.repeatForever(blink)
        light.run(blinkForever)
        
        return light
    }
    
    @objc func newRock() {
        let rock = SKSpriteNode(imageNamed: "rock.png")
        rock.size = CGSize(width: 40, height: 40)
        let remove = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
        rock.position = CGPoint(x: CGFloat(arc4random()).truncatingRemainder(dividingBy: self.size.width), y: self.size.height)
        rock.name = "rocks"
        rock.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        rock.run(remove)
        self.addChild(rock)
    }
    
    @objc func newCoin() {
        let coin = SKSpriteNode(imageNamed: "coin.png")
        coin.size = CGSize(width: 30, height: 30)
        let remove = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
        coin.position = CGPoint(x: CGFloat(arc4random()).truncatingRemainder(dividingBy: self.size.width), y: self.size.height)
        coin.name = "coins"
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        coin.physicsBody?.usesPreciseCollisionDetection = true
        coin.run(remove)
        self.addChild(coin)
    }
    
    @objc func handpan(recognizer: UIPanGestureRecognizer) {
        let viewLocation = recognizer.location(in: view)
        let sceneLocation = convertPoint(fromView: viewLocation)
        let moveAction = SKAction.moveTo(x: sceneLocation.x, duration: 0.1)
        self.childNode(withName: "ships")!.run(moveAction)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "ships" {
            secondBody = contact.bodyB
        }
        else{
            secondBody = contact.bodyA
        }
        
        if secondBody.node?.name == "rocks" {
            print("You lose!\n")
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.score = self.scoreValue
            self.view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenVertical(withDuration: 0.5))
        }
        else if secondBody.node?.name == "coins"{
            secondBody.node?.removeFromParent()
            scoreValue += 100
            scoreLabel.text = "Score: \(scoreValue)"
            print("Get point 100!\n")
        }
    }

}
