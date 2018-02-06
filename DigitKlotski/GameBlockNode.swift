//
//  GameBlockNode.swift
//  DigitKlotski
//
//  Created by chenjiesheng on 2018/2/6.
//  Copyright © 2018年 陈杰生. All rights reserved.
//

import SpriteKit

enum GameBlockType: Int {
    case Digit = 0
    case Empty
}

class GameBlockNode: SKSpriteNode {
    var positionIndex:Int = 0
    var labelNode: SKLabelNode!
    var digit: Int = 0 {
        didSet {
            self.labelNode.text = "\(self.digit)"
        }
    }
    var originColor: SKColor = .clear
    override var color: UIColor{
        set {
            super.color = newValue
            self.originColor = newValue
        }
        get {
            return super.color
        }
    }
    var type: GameBlockType = .Digit {
        didSet {
            switch type {
            case .Digit:
                self.labelNode.isHidden = false
                self.color = self.originColor
            case .Empty:
                self.labelNode.isHidden = true
                self.color = .clear
            }
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.originColor = color
        self.createComponent()
    }
    
    public convenience init(color: UIColor, size: CGSize, digit: Int) {
        self.init(texture: nil, color: color, size: size)
        self.digit = digit
        self.updateUI()
    }
    
    public convenience init(texture: SKTexture?, size: CGSize, digit: Int) {
        self.init(texture: texture, color: .clear, size: size)
        self.digit = digit
        self.updateUI()
    }
    
    func createComponent() {
        self.labelNode = SKLabelNode()
        self.labelNode.fontSize = 100
        self.labelNode.fontColor = SKColor.white
        self.addChild(self.labelNode)
        self.labelNode.position = CGPoint(x: 0, y: 0)
    }
    
    func updateUI() {
        self.labelNode.text = "\(self.digit)"
        self.labelNode.position = CGPoint(x: 0, y: -self.labelNode.frame.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
