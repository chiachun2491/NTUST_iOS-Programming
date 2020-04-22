//
//  GameOverScene.swift
//  homework3
//
//  Created by Jeffery Ho on 2020/4/22.
//  Copyright © 2020 Jeffery Ho. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    var score: Int = 0
    
    override func didMove(to view: SKView) {
         createScene()
    }
    
    func createScene() {
        let bg = SKSpriteNode(imageNamed: "hellobgd.jpg")
        bg.size.width = self.size.width
        bg.size.height = self.size.height
        bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bg.zPosition = -1
        
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.name = "scoreLabel"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 80)
        scoreLabel.fontName = "Avenir-Oblique"
        scoreLabel.fontSize = 28
        
        let restartLabel = SKLabelNode(text: "Touch screen to restart")
        restartLabel.name = "restartLabel"
        restartLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        restartLabel.fontName = "Avenir-Oblique"
        restartLabel.fontSize = 20
        restartLabel.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])))
        
        self.addChild(bg)
        self.addChild(scoreLabel)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mainScene = MainScene(size: self.size)
        let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
        self.view?.presentScene(mainScene, transition: doors)
    }
}
