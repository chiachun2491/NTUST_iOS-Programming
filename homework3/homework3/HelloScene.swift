//
//  HelloScene.swift
//  homework3
//
//  Created by Jeffery Ho on 2020/4/22.
//  Copyright © 2020 Jeffery Ho. All rights reserved.
//

import UIKit
import SpriteKit

class HelloScene: SKScene {
    override func didMove(to view: SKView) {
         createScene()
    }
    
    func createScene() {
        let bg = SKSpriteNode(imageNamed: "hellobgd.jpg")
        bg.size.width = self.size.width
        bg.size.height = self.size.height
        bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bg.zPosition = -1
        
        let helloLabel = SKLabelNode(text: "Space 🚀 Adventure")
        helloLabel.name = "label"
        helloLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        helloLabel.fontName = "Avenir-Oblique"
        helloLabel.fontSize = 28
        
        let startLabel = SKLabelNode(text: "Touch screen to start")
        startLabel.name = "startLabel"
        startLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        startLabel.fontName = "Avenir-Oblique"
        startLabel.fontSize = 20
        startLabel.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])))
        
        self.addChild(bg)
        self.addChild(helloLabel)
        self.addChild(startLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let startLabelNode = self.childNode(withName: "startLabel")
        startLabelNode?.removeFromParent()
        
        let labelNode = self.childNode(withName: "label")
        let zoomIn = SKAction.scale(to: 4.0, duration: 2)
        let zoomOut = SKAction.scale(by: 0.5, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let moveSeq = SKAction.sequence([zoomOut, zoomIn, remove])
        labelNode?.run(moveSeq, completion: {
            let mainScene = MainScene(size: self.size)
            let doors = SKTransition.doorsOpenVertical(withDuration: 0.5)
            self.view?.presentScene(mainScene, transition: doors)
        })
    }
}
