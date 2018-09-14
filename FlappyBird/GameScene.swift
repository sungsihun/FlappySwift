//
//  GameScene.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import SpriteKit



class GameScene: SKScene, SKPhysicsContactDelegate{
  
  
  
    let verticalPipeGap = 180.0
    
    var bird:SKSpriteNode!
    var skyColor:SKColor!
    var coke1:SKTexture!
    var coke2:SKTexture!
    var coke3:SKTexture!
    var coke4:SKTexture!

    var movePipesAndRemove:SKAction!
    var moving:SKNode!
    var pipes:SKNode!
    var canRestart = Bool()
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
  

    
    override func didMove(to view: SKView) {
      
      
        canRestart = true
        
        // setup physics
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: -5.0 )
        self.physicsWorld.contactDelegate = self
        
        // setup background color
//        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = .white

      
        moving = SKNode()
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)
        
        // ground
        let groundTexture = SKTexture(imageNamed: "land")
        groundTexture.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.02 * groundTexture.size().width * 2.0))

        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / ( groundTexture.size().width * 1 )) {
            let i = CGFloat(i)
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(1.0)
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // skyline
//        let skyTexture = SKTexture(imageNamed: "sky")
//        skyTexture.filteringMode = .nearest
//        
//        let moveSkySprite = SKAction.moveBy(x: -skyTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.1 * skyTexture.size().width * 2.0))
//        let resetSkySprite = SKAction.moveBy(x: skyTexture.size().width * 2.0, y: 0, duration: 0.0)
//        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
//        
//        for i in 0 ..< 2 + Int(self.frame.size.width / ( skyTexture.size().width * 2 )) {
//            let i = CGFloat(i)
//            let sprite = SKSpriteNode(texture: skyTexture)
//            sprite.setScale(2.0)
//            sprite.zPosition = -20
//            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
//            sprite.run(moveSkySpritesForever)
//            moving.addChild(sprite)
//        }
        
        // create the pipes textures
        coke1 = SKTexture(imageNamed: "coke")
        coke1.filteringMode = .nearest
        coke2 = SKTexture(imageNamed: "coke")
        coke2.filteringMode = .nearest
        coke3 = SKTexture(imageNamed: "coke")
        coke3.filteringMode = .nearest
        coke4 = SKTexture(imageNamed: "dietCoke")
        coke4.filteringMode = .nearest
      
        // create the pipes movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 3.0 * coke1.size().width)
        let movePipes = SKAction.moveBy(x: -distanceToMove, y:0.0, duration:TimeInterval(0.003 * distanceToMove))
 
      
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn the pipes
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: TimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        // setup our bird
        let birdTexture1 = SKTexture(imageNamed: "bacon-burger")
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(imageNamed: "bacon-burger")
        birdTexture2.filteringMode = .nearest
        
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(1.8)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        bird.run(flap)
        
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(bird)
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 0.1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
      
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
      
        scoreLabelNode.fontColor = .darkGray
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
      
 
    }


    
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.position = CGPoint( x: self.frame.size.width + self.coke1.size().width * 2, y: 0.0 )
        pipePair.zPosition = -10
        
        let height = UInt32( self.frame.size.height / 4)
        let y = Double(arc4random_uniform(height) + height)
        
        let coke2 = SKSpriteNode(texture: self.coke2)
        coke2.setScale(2.0)
        coke2.position = CGPoint(x: 0.0, y: y + Double(coke2.size.height) + verticalPipeGap)
        
        
        coke2.physicsBody = SKPhysicsBody(rectangleOf: coke2.size)
        coke2.physicsBody?.isDynamic = false
        coke2.physicsBody?.categoryBitMask = pipeCategory
        coke2.physicsBody?.contactTestBitMask = birdCategory
//        pipePair.addChild(pipeDown)
      
        let coke3 = SKSpriteNode(texture: self.coke3)
        coke3.setScale(2.0)
        coke3.position = CGPoint(x: 0.0, y: y + Double(coke3.size.height) - verticalPipeGap)
      
      
        coke3.physicsBody = SKPhysicsBody(rectangleOf: coke3.size)
        coke3.physicsBody?.isDynamic = false
        coke3.physicsBody?.categoryBitMask = pipeCategory
        coke3.physicsBody?.contactTestBitMask = birdCategory
      
      
      
      let coke4 = SKSpriteNode(texture: self.coke4)
      coke4.setScale(2.0)
      coke4.position = CGPoint(x: 0.0, y: y + Double(coke4.size.height) + 100.0)
      
      
      coke4.physicsBody = SKPhysicsBody(rectangleOf: coke4.size)
      coke4.physicsBody?.isDynamic = false
      coke4.physicsBody?.categoryBitMask = pipeCategory
      coke4.physicsBody?.contactTestBitMask = birdCategory
      
        let coke1 = SKSpriteNode(texture: self.coke1)
        coke1.setScale(2.0)
        coke1.position = CGPoint(x: 0.0, y: y)
        
        coke1.physicsBody = SKPhysicsBody(rectangleOf: coke1.size)
        coke1.physicsBody?.isDynamic = false
        coke1.physicsBody?.categoryBitMask = pipeCategory
        coke1.physicsBody?.contactTestBitMask = birdCategory
      
        let randomNum = Int(arc4random_uniform(5))
//        print(randomNum)
        if randomNum == 0 {
            pipePair.addChild(coke2)
            pipePair.addChild(coke1)
        } else if randomNum == 1 {
            pipePair.addChild(coke1)
//            pipePair.addChild(coke2)
            pipePair.addChild(coke4)
        } else if randomNum == 2 {
//            pipePair.addChild(coke1)
            pipePair.addChild(coke4)
            pipePair.addChild(coke3)
        } else if randomNum == 3 {
            pipePair.addChild(coke2)
//            pipePair.addChild(coke4)
        } else {
            pipePair.addChild(coke1)
//            pipePair.addChild(coke2)
//            pipePair.addChild(coke3)
//           pipePair.addChild(coke4)

        }
      
      
        let contactNode = SKNode()
        contactNode.position = CGPoint( x: coke2.size.width + bird.size.width / 2, y: self.frame.midY )
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize( width: coke1.size.width, height: self.frame.size.height ))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        pipePair.run(movePipesAndRemove)
        pipes.addChild(pipePair)
        
    }
    
    func resetScene (){
        // Move bird to original position and reset velocity
        bird.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        bird.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        
        // Remove all existing pipes
        pipes.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Restart animation
        moving.speed = 1
      
        // Reset gameover
//        gameOver.removeFromParent()
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed > 0  {
            for _ in touches { // do we need all touches?
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            }
        } else if canRestart {
            self.resetScene()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let value = bird.physicsBody!.velocity.dy * ( bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )
        bird.zRotation = min( max(-1, value), 0.5 )
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
      let gameOverScene = GameOverScene(size: self.size)

        if moving.speed > 0 {
            if ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                // Bird has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
              
              
              if score%10 == 0 {
                // Add a little visual feedback for the score increment
                scoreLabelNode.fontColor = .red
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 7.0, duration:TimeInterval(0.3)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
              } else {
                // Add a little visual feedback for the score increment
                scoreLabelNode.fontColor = .darkGray
                scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
              }
              
            } else {
                
                moving.speed = 0
                bird.physicsBody?.collisionBitMask = worldCategory
                bird.run(  SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1), completion:{self.bird.speed = 0 })
                
                
                // Flash background if contact is detected
                self.removeAction(forKey: "flash")
                self.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.run({
                    self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                    }),SKAction.wait(forDuration: TimeInterval(0.05)), SKAction.run({
                        self.backgroundColor = self.skyColor
                        }), SKAction.wait(forDuration: TimeInterval(0.05))]), count:4), SKAction.run({
                            self.canRestart = true
                            })]), withKey: "flash")
      
                view?.presentScene(gameOverScene, transition: SKTransition.flipHorizontal(withDuration: 0.8))
            }
        }
    }
  
    
  
}
