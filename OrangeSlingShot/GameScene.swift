//
//  GameScene.swift
//  OrangeSlingShot
//

import SpriteKit

class GameScene: SKScene {

    var orangeTree: SKSpriteNode!
    var orange: Orange?
    var touchStart: CGPoint = .zero
    //launch vector
    var shapeNode = SKShapeNode()
    
    override func didMove(to view: SKView) {
        orangeTree = childNode(withName: "tree") as? SKSpriteNode
        shapeNode.lineWidth = 20
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if atPoint(location).name == "tree" {
            
            orange = Orange()
            orange?.physicsBody?.isDynamic = false
            orange?.position = location
            addChild(orange!)
            
            touchStart = location
//            let vector = CGVector(dx: 100, dy: 0)
//            orange?.physicsBody?.applyImpulse(vector)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        orange?.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        let dx = touchStart.x - location.x
        let dy = touchStart.y - location.y
        let vector = CGVector(dx: dx, dy: dy)
        
        orange?.physicsBody?.isDynamic = true
        orange?.physicsBody?.applyImpulse(vector)
    }
    
}
