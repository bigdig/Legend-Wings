//
//  StartGame.swift
//  Angelica Fighti
//
//  Created by Guan Wong on 12/22/16.
//  Copyright © 2016 Wong. All rights reserved.
//

// Height: 736, Width: 414  -> iPhone 7 Plus

import Foundation
import SpriteKit
import AVFoundation

let PLAYER_SPRITES_DIR = "Sprites/Player"
let ENEMY_SPRITES_DIR = "Sprites/Enemy/Standard"
let BOSS_SPRITES_DIR = "Sprites/Enemy/Boss"
let ITEMS_SPRITES_DIR = "Sprites/Items"

let SOUND_EFFECT_PUFF = "SoundEffects/puff.m4a"
let SOUND_EFFECT_COIN = "SoundEffects/getcoin.m4a"

class StartGame:SKScene, SKPhysicsContactDelegate{
    
     deinit{
     print("STARTGAME is being deInitialized. REMOVE THIS FUNCTION WHEN IT IS SENDING TO APPSTORE");
     }
    
    var gameinfo = GameInfo()
    
    override func didMove(to view: SKView) {
        
        removeUIViews()
        
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanFrom(recognizer:)))
        
            self.view?.addGestureRecognizer(gestureRecognizer)
        
        
        self.anchorPoint = CGPoint(x: 0, y: 0)

        
        
        print ("Y: \(view.bounds.size.height)")
        print ("X: \(view.bounds.size.width)")
        
       
        load()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // good
        movingSky()
       // let toon = gameinfo.account.getCurrentToon()
        
    }
     
 
    
    

    func load(){
        
        // For Debug Use only
        view?.showsPhysics = false
        
        // Setting up delegate for Physics World & Set up gravity
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        let bground1 = SKSpriteNode()
        bground1.texture = SKTexture(imageNamed: "backgrounds/type1/bg\(randomInt(min: 1, max: 6)).png")
        bground1.size = CGSize(width: screenSize.width, height: screenSize.height)
        bground1.position = CGPoint(x: screenSize.width/2, y: 0)
        bground1.zPosition = -1
        bground1.name = "sky"
        self.addChild(bground1)
        
        let bground2 = SKSpriteNode()
        bground2.texture = SKTexture(imageNamed: "backgrounds/type1/bg\(randomInt(min: 1, max: 6)).png")
        bground2.size = CGSize(width: screenSize.width, height: screenSize.height)
        bground2.position = CGPoint(x: screenSize.width/2, y: screenSize.height)
        bground2.name = "sky"
        bground2.zPosition = -1
        self.addChild(bground2)
 
        // Check if any error from loading gameinfo
        let check = gameinfo.load(scene: self)
        
        if(!check.0){
            print("LOADING ERROR: ", check.1)
            return
        }
        
        gameinfo.account.getCurrentToon().getNode().run(SKAction.scale(by: 0.8, duration: 0.1))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(gameinfo.update), SKAction.wait(forDuration: 0.01)])))
        
        
    }
    
    func movingSky(){
        self.enumerateChildNodes(withName: "sky", using: ({(node, error ) in
            node.position.y -= 2
            if (node.position.y <= -screenSize.height/2){
                node.position.y = screenSize.height*1.5
            }
            
        }))
    }
 
    
    func removeUIViews(){
        for view in (view?.subviews)! {
            view.removeFromSuperview()
        }
        
    }
    
  @objc func handlePanFrom(recognizer : UIPanGestureRecognizer) {
        
        let toon = self.gameinfo.account.getCurrentToon()
        let player = toon.getNode()
        
        if recognizer.state == .began {
           // print ("GESTURE PAN started")
           // var touchLocation = recognizer.location(in: self.view)
           // touchLocation = self.convertPoint(fromView: touchLocation)
        
        } else if recognizer.state == .changed {
            let locomotion = recognizer.translation(in: recognizer.view)
           player.position.x = ceil(toon.getNode().position.x) + ceil((locomotion.x * 1.8))
            
          //  print (toon.getNode().position)
            recognizer.setTranslation(CGPoint(x: 0,y: 0), in: self.view)
            if (player.position.x < 50 ){
                player.position.x = 50
            }
            else if (toon.getNode().position.x > 374){
                player.position.x = 374
            }
 
            if (locomotion.x < -1){
                player.run(SKAction.rotate(toAngle: 0.0872665, duration: 0.1))
            }
            else if (locomotion.x > 0.5){
               player.run(SKAction.rotate(toAngle: -0.0872665, duration: 0.1))
            }
            else if (locomotion.x == 0.0){
                player.run(SKAction.rotate(toAngle: 0, duration: 0.1))
            }
            
            toon.updateProjectile()
        } else if recognizer.state == .ended {
            player.run(SKAction.rotate(toAngle: 0, duration: 0.1))
        }
        else if recognizer.state == .cancelled{
            print ("FAILED CANCEL")
        }
        else if recognizer.state == .failed{
            print ("FAILED")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var higherNode:SKSpriteNode?
        var lowerNode:SKSpriteNode?
        
        //let player = gameinfo.account.getCurrentToon()
        let enemy = gameinfo.enemy
       let boss = gameinfo.boss
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask{
            higherNode = contact.bodyA.node as! SKSpriteNode?
            lowerNode = contact.bodyB.node as! SKSpriteNode?
            
          //  print ("\(higherNode?.name!) has higher bit than \(lowerNode?.name!)")
          //  print ("LOOOOOOK[1]: \(contact.bodyA.contactTestBitMask) IS GREATER THAN \(contact.bodyB.contactTestBitMask)")
        }
        else{
            higherNode = contact.bodyB.node as! SKSpriteNode?
            lowerNode = contact.bodyA.node as! SKSpriteNode?
            
        //    print ("\(lowerNode?.name!) has higher bit than \(higherNode?.name!)")
        //    print ("LOOOOOOK[2]: \(contact.bodyB.contactTestBitMask) IS GREATER THAN \(contact.bodyA.contactTestBitMask)")
        }
        
        if (higherNode == nil || lowerNode == nil){
            return
        }
        
        if (higherNode?.physicsBody?.categoryBitMask == PhysicsCategory.Imune){
         //   print ("omg..")
            lowerNode!.removeFromParent()
            return
        }
   
        if lowerNode!.name! == "enemyOne"{
                enemy.decreaseHP(ofTarget: lowerNode!, hitBy: higherNode!)
            }
        else if lowerNode!.name! == "Enemy_Boss"{
            boss.decreaseHP(ofTarget: lowerNode!, hitBy: higherNode!)
        }
        else if lowerNode!.name! == "toon" && higherNode!.name! == "coin"{

            self.run(self.gameinfo.mainAudio.getAction(type: .Coin))
            
         self.gameinfo.addCoin(amount: 1)
            higherNode!.removeFromParent()
        }
        
        
        else if lowerNode!.name! == "toon" && higherNode!.name! != "coin"{
            
  
                for gesture in (view?.gestureRecognizers)!{
                    view?.removeGestureRecognizer(gesture)
                }
            gameinfo.boss.delegate = nil
            gameinfo.enemy.delegate = nil
      
            for childNode in self.children{
                childNode.removeAllActions()
            }
            
            lowerNode!.removeAllActions()
            higherNode!.removeAllActions()
            
            self.removeAllChildren()
            
            self.removeAllActions()
            
            self.gameinfo.mainAudio.stop()
            
            let scene = EndGame(size: self.size)
            scene.collectedCoins = gameinfo.getCurrentGold()
            view?.presentScene(scene)
            
            
        }
        
      //  print ("lower: \(lowerNode!)")
      //  print("higher: \(higherNode!)")

        // bullets, enemy...
        
        if (higherNode?.name! == "bullet"){
            higherNode!.removeAllActions()
           higherNode!.removeFromParent() 
        }
        
        
        
    }

}
