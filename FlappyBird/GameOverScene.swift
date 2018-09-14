//
//  GameOverScene.swift
//  FlappyBird
//
//  Created by NICE on 2018-09-14.
//  Copyright © 2018 Fullstack.io. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
  
  var gameOver: SKSpriteNode!
  
  override init(size: CGSize) {
    super.init(size: size)

  }
  
  override func didMove(to view: SKView) {
    gameOver = SKSpriteNode(imageNamed: "gameOverBackground")
    gameOver.size = frame.size
    gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(gameOver)
    
    backgroundColor = SKColor.white
    
    let message = "GAME OVER"
    
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 80
    label.fontColor = SKColor.white
    label.position = CGPoint(x: size.width/2, y: size.height*0.8)
    addChild(label)
  }
  
 
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let gameScene = GameScene(fileNamed: "GameScene") else {
      fatalError("GameScene not found")
    }
    let transition = SKTransition.flipHorizontal(withDuration: 0.8)
    gameScene.scaleMode = .aspectFill
    view?.presentScene(gameScene, transition: transition)
  }
}
