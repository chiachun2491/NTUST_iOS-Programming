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
        
        let textLabel = SKLabelNode(text: "You lose!")
        textLabel.name = "textLabel"
        textLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 80)
        textLabel.fontName = "Avenir-Oblique"
        textLabel.fontSize = 40
        
        self.addChild(bg)
        self.addChild(textLabel)
        
        let alert = UIAlertController(title: "Score: \(score)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Again", style: .default) { (_) in
            let mainScene = MainScene(size: self.size)
            let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
            self.view?.presentScene(mainScene, transition: doors)
        })
        
        self.scene?.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
