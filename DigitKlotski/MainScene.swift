//
//  MainScene.swift
//  DigitKlotski
//
//  Created by chenjiesheng on 2018/2/4.
//  Copyright © 2018年 陈杰生. All rights reserved.
//

import SpriteKit

enum GameStatus : Int{
    case UnStart = 0
    case Playing
    case Pause
    case Stop
}

enum GameMode : Int {
    case Mode3x3 = 3
    case Mode4x4 = 4
    case Mode5x5 = 5
}

class MainScene: SKScene {

    private var mapNode: SKSpriteNode!
    private var timeLabel: SKLabelNode!
    private var operationButton: SKLabelNode!
    private var backgroundNode: SKSpriteNode!
    private var numBlockNodes: Array<GameBlockNode>! = Array<GameBlockNode>()
    private var emptyNodes: GameBlockNode!
    
    private var blockPadding: CGFloat = 0
    private var blockWidth: CGFloat = 0
    private var blockHalfWidth: CGFloat = 0
    private var blockBorderPadding: CGFloat = 0
    private var blockNum: Int = 0
    
    var lastTime: TimeInterval = 0
    var pastTime: TimeInterval = 0
    var gameStatus: GameStatus = .UnStart
    var gameMode: GameMode = .Mode3x3

    override func sceneDidLoad() {
        super.sceneDidLoad()
        if let node = self.childNode(withName: "background_node") as? SKSpriteNode {
            self.backgroundNode = node
        }
        
        if let node = self.backgroundNode.childNode(withName: "map") as? SKSpriteNode {
            self.mapNode = node
        }
        if let timeLabel = self.backgroundNode.childNode(withName: "time_label") as? SKLabelNode {
            self.timeLabel = timeLabel
        }
        if let operationButton = self.backgroundNode.childNode(withName: "operation_button") as? SKLabelNode {
            self.operationButton = operationButton
        }
        self.initUI()
        self.createComponent()
        self.refreshUI()
    }
    
    private func initUI() {
        let width = self.backgroundNode.size.width
        let mapWidth = width - 40
        self.mapNode.size = CGSize(width: mapWidth, height: mapWidth)
        self.initBlockUIConfig()
    }
    
    private func refreshUI() {
        self.refresBlocks()
    }
    
    private func initBlockUIConfig() {
        self.blockPadding = ceil(4.0 / 375.0 * self.mapNode.size.width)
        self.blockWidth = floor((self.mapNode.size.width - blockPadding * CGFloat(self.gameMode.rawValue + 1)) / CGFloat(self.gameMode.rawValue))
        self.blockHalfWidth = floor(self.blockWidth / 2)
        self.blockBorderPadding = ceil(self.blockPadding + self.blockHalfWidth)
        self.blockNum = self.gameMode.rawValue * self.gameMode.rawValue
    }
    
    private func refresBlocks() {
        let blockWidth = self.blockWidth
        let halfBlockWidth = self.blockHalfWidth
        let blockBorderPadding = self.blockBorderPadding;
        var blockPosition = CGPoint(x: -ceil(self.mapNode.size.width / 2), y: self.mapNode.size.height / 2);
        let blockSize = CGSize(width: blockWidth, height: blockWidth)
        blockPosition.x += blockBorderPadding;
        blockPosition.y -= blockBorderPadding;
        if (self.numBlockNodes.count > 1) {
            for i in 0 ..< self.numBlockNodes.count{
                let block = self.numBlockNodes[i]
                block.size = blockSize
                block.position = blockPosition
                if (i + 1) % self.gameMode.rawValue == 0 {
                    blockPosition = CGPoint(x: -self.mapNode.size.width / 2 + blockBorderPadding, y: blockPosition.y - blockBorderPadding - halfBlockWidth)
                } else {
                    blockPosition.x += blockBorderPadding + halfBlockWidth
                }
            }
        }
    }
    
    private func createComponent() {
        let blockNum = self.blockNum
        let blockWidth = self.blockWidth
        let blockSize = CGSize(width: blockWidth, height: blockWidth)
        for i in 1...blockNum {
            let block = GameBlockNode(color: .gray, size:blockSize, digit: i)
            self.mapNode.addChild(block)
            self.numBlockNodes.append(block)
            block.positionIndex = i
        }
        self.emptyNodes = self.numBlockNodes.last!
        self.emptyNodes.type = .Empty
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if self.gameStatus == .Playing {
            let duration = currentTime - self.lastTime
            self.lastTime = currentTime
            self.pastTime += duration
            self.updateGameTimeLabel()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self.backgroundNode)
            if self.operationButton.contains(location) {
                self.operationButtonClicked()
            }
            if self.checkValidBlockTouch(with: touch) {
                return
            }
        }
    }
    
    func operationButtonClicked() {
        switch self.gameStatus {
        case .UnStart:
            self.updateGameStatus(new: .Playing)
            self.gameStart()
        case .Pause:
            self.updateGameStatus(new: .Playing)
            self.gameContinue()
        case .Stop:
            self.updateGameStatus(new: .Playing)
            self.gameStart()
        case .Playing:
            self.updateGameStatus(new: .Pause)
            self.gamePause()
        }
    }
    
    func checkValidBlockTouch(with touch: UITouch) -> Bool {
        if (self.gameStatus != .Playing) {
            return false
        }
        let location = touch.location(in: self.mapNode)
        for block in self.numBlockNodes {
            if block.contains(location) {
                if self.checkBlockCanMove(block: block) {
                    self.blockClicked(at: block)
                    return true
                }
            }
        }
        return false
    }
    
    func checkBlockCanMove(block: GameBlockNode) -> Bool {
        let emptyNodeIndex = self.emptyNodes.positionIndex
        let curIndex = block.positionIndex
        let diff = abs(curIndex - emptyNodeIndex)
        if (diff == 1 || diff == self.gameMode.rawValue) {
            return true
        }
        return false
    }
    
    func blockClicked(at block: GameBlockNode) {
        let targetPosition = self.emptyNodes.position
        let emptyNodeTargetPosition = block.position
        let targetIndex = self.emptyNodes.positionIndex
        let emptyNodeIndex = block.positionIndex
        self.emptyNodes.positionIndex = emptyNodeIndex
        block.positionIndex = targetIndex
        block.run(SKAction.move(to: targetPosition, duration: 0.1))
        self.emptyNodes.position = emptyNodeTargetPosition
    }
    
    func updateGameStatus(new gameStatus:GameStatus) {
        self.gameStatus = gameStatus;
        switch gameStatus {
        case .UnStart:
            self.operationButton.text = "开始"
        case .Stop:
            self.operationButton.text = "开始"
        case .Playing:
            self.operationButton.text = "暂停"
        case .Pause:
            self.operationButton.text = "继续"
        }
    }
    
    func updateGameTimeLabel() {
        let pastTime100: Int = Int(self.pastTime * 100)
        
        let timeStr = String(format: "%02d : %02d : %02d", pastTime100 / 6000,pastTime100 / 100 % 60,pastTime100 % 100)
        self.timeLabel.text = timeStr
        self.timeLabel.position = CGPoint(x: self.backgroundNode.frame.midX, y: self.timeLabel.position.y)
    }
    
    func gameStart() {
        self.lastTime = CACurrentMediaTime()
        self.updateBlockPosition()
    }
    
    func updateBlockPosition() {
        self.numBlockNodes = self.numBlockNodes.sorted{ return $0.digit < $1.digit }
        var positionArrayTmp: Array<Int> = Array()
        for i in 1...self.numBlockNodes.count {
            positionArrayTmp.append(i)
        }
        var finalPositionArray: Array<Int> = Array()
        for _ in 1...self.numBlockNodes.count {
            let randomIndex:Int = Int(arc4random() % UInt32(positionArrayTmp.count))
            if (randomIndex < positionArrayTmp.count) {
                let position = positionArrayTmp[randomIndex]
                positionArrayTmp.remove(at: randomIndex)
                finalPositionArray.append(position)
            }
        }
        if (finalPositionArray.count > 0) {
            for i in 0 ..< finalPositionArray.count {
                let position = finalPositionArray[i]
                let block = self.numBlockNodes[i]
                block.positionIndex = position
            }
        }
        self.updateBlockPositionUI()
    }
    
    func updateBlockPositionUI() {
        for block in self.numBlockNodes {
            let position = self.targetPointWithPosition(at: block.positionIndex)
            self.moveAnimation(with: block, to: position)
        }
    }
    
    func moveAnimation(with block: SKNode, to position: CGPoint) {
        block.run(SKAction.move(to: position, duration: 0.25))
    }
    
    func targetPointWithPosition(at index: Int) -> CGPoint {
        var position = CGPoint(x: -self.mapNode.size.width / 2 + self.blockBorderPadding, y: self.mapNode.size.height / 2 - self.blockBorderPadding)
        let yIndex = CGFloat(index / self.gameMode.rawValue) + (index % self.gameMode.rawValue == 0 ? 0 : 1)
        let xIndex = CGFloat(index - Int(yIndex - 1) * self.gameMode.rawValue)
        let xOffset = (xIndex - 1) * (self.blockWidth + self.blockPadding)
        let yOffset = (yIndex - 1) * (self.blockWidth + self.blockPadding)
        position.x += xOffset
        position.y -= yOffset
        return position
    }
    
    func gameContinue() {
        self.lastTime = CACurrentMediaTime()
    }
    
    func gamePause() {
    }
}
