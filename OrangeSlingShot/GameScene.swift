//
//  GameScene.swift
//  OrangeSlingShot
//

import SpriteKit

class GameScene: SKScene {

    var orangeTree: SKSpriteNode!
    var orange: Orange?
    var touchStart: CGPoint = .zero
    var shapeNode = SKShapeNode()
    var boundary = SKNode()
    var numOfLevels: UInt32 = 4
    var points = SKLabelNode()
    var score: Int = 0
    
    // Class method to load .sks files
    static func Load(level: Int) -> GameScene? {
      return GameScene(fileNamed: "Level-\(level)")
    }
    
    func removeOrangeAfterDelay(node: SKNode) {
        let wait = SKAction.wait(forDuration: 6)
        let addSmoke = SKAction.run { [weak self] in
            self?.skullDestroyedParticles(point: node.position)
        }
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, addSmoke, remove])
        node.run(sequence)
    }
    
    override func didMove(to view: SKView) {
        orangeTree = childNode(withName: "tree") as? SKSpriteNode
        shapeNode.lineWidth = 20
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        physicsWorld.contactDelegate = self
        
        // Setup the boundaries
          boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
          let background = childNode(withName: "background") as? SKSpriteNode
          boundary.position = CGPoint(x: (background?.size.width ?? 0) / 2, y: (background?.size.height ?? 0) / 2)
          addChild(boundary)
        
        
        let pointsLabel = SKLabelNode(text: "Score: 0")
        pointsLabel.name = "pointsLabel"
        pointsLabel.fontColor = SKColor.black
        pointsLabel.fontSize = 50
        pointsLabel.fontName = "Helvetica-Bold"
        pointsLabel.position = CGPoint(x: -520, y: 220)
        addChild(pointsLabel)
        
        // Add the Sun to the scene
        let sun = SKSpriteNode(imageNamed: "Sun")
        sun.name = "sun"
        sun.position.x = size.width / 2 - (sun.size.width * 0.75)
        sun.position.y = size.height / 2 - (sun.size.height * 0.75)
        addChild(sun)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch on the screen
        let touch = touches.first!
        let location = touch.location(in: self)
        
        // Check if the touch was on the Orange Tree
        if atPoint(location).name == "tree" {
            // Create the orange and add it to the scene at the touch location
            orange = Orange()
            removeOrangeAfterDelay(node: orange!)
            orange?.physicsBody?.isDynamic =  false
            orange?.position = location
            addChild(orange!)
            
            // Store the location of the touch
            touchStart = location
        }
        
        // Check whether the sun was tapped and change the level
        for node in nodes(at: location) {
            if node.name == "sun" {
                let n = Int(arc4random() % numOfLevels + 1)
                if let scene = GameScene.Load(level: n) {
                    scene.scaleMode = .aspectFill
                    if let view = view {
                        view.presentScene(scene)
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        orange?.position = location
        
        let path = UIBezierPath()
        path.move(to: touchStart)
        path.addLine(to: location)
        shapeNode.path = path.cgPath
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        let dx = (touchStart.x - location.x) * 0.5
        let dy = (touchStart.y - location.y) * 0.5
        let vector = CGVector(dx: dx, dy: dy)
        
        orange?.physicsBody?.isDynamic = true
        orange?.physicsBody?.applyImpulse(vector)
        shapeNode.path = nil
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("Score: \(score)")
        if let scoreLabel = childNode(withName: "pointsLabel") as? SKLabelNode {
            scoreLabel.text = "Score: \(score)"
        }

        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        if contact.collisionImpulse > 15 {
            if nodeA?.name == "skull" {
                removeSkull(node: nodeA!)
                skullDestroyedParticles(point: nodeA!.position)
                score += 1 // Add 1 to the score
            } else if nodeB?.name == "skull" {
                removeSkull(node: nodeB!)
                skullDestroyedParticles(point: nodeB!.position)
                score += 1 // Add 1 to the score
            }
        }
    }
    
    func removeSkull(node: SKNode){
        node.removeFromParent()
    }
}

extension GameScene {
  func skullDestroyedParticles(point: CGPoint) {
      if let explosion = SKEmitterNode(fileNamed: "Explosion") {
        addChild(explosion)
        explosion.position = point
        let wait = SKAction.wait(forDuration: 1)
        let removeExplosion = SKAction.removeFromParent()
        explosion.run(SKAction.sequence([wait, removeExplosion]))
      }
    }
}

extension GameScene {
    func orangeDestroySmoke(point: CGPoint) {
        if let explosion = SKEmitterNode(fileNamed: "Smoke") {
          addChild(explosion)
          explosion.position = point
          let wait = SKAction.wait(forDuration: 1)
          let removeExplosion = SKAction.removeFromParent()
          explosion.run(SKAction.sequence([wait, removeExplosion]))
        }
      }
}

