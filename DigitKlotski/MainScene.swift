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

class MainScene: SKScene {

    private var mapNode: SKSpriteNode!
    private var timeLabel: SKLabelNode!
    private var operationButton: SKLabelNode!
    private var backgroundNode: SKSpriteNode!
    var lastTime: TimeInterval = 0
    var pastTime: TimeInterval = 0
    var gameStatus: GameStatus = .UnStart

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
        self.refreshUI()
    }
    
    func refreshUI() {
        let width = self.frame.width + self.frame.minX
        let mapWidth = width - 20
        self.mapNode.size = CGSize(width: mapWidth / self.frame.width * 100, height: mapWidth / self.frame.height * 100)
        self.mapNode.position = CGPoint(x: self.frame.midX, y: self.mapNode.position.y)
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
    }
    
    func gameContinue() {
        self.lastTime = CACurrentMediaTime()
    }
    
    func gamePause() {
    }
}
