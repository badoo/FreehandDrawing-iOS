//
//  FreehandDrawController.swift
//  FreehandDrawing-iOS
//
//  Created by Miguel Angel Quinones on 03/06/2015.
//  Copyright (c) 2015 badoo. All rights reserved.
//

import UIKit

class FreehandDrawController : NSObject {
    var color: UIColor = UIColor.blackColor()
    var width: CGFloat = 5.0
    
    required init(canvas: protocol<Canvas, DrawCommandReceiver>, view: UIView) {
        self.canvas = canvas
        super.init()
        
        self.setupGestureRecognizersInView(view)
    }
    
    // MARK: Gestures
    
    private func setupGestureRecognizersInView(view: UIView) {
        // Pan gesture recognizer to track lines
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        view.addGestureRecognizer(panRecognizer)
        
        // Tap gesture recognizer to track points
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(sender.view)
        switch sender.state {
        case .Began:
            self.startAtPoint(point)
        case .Changed:
            self.continueAtPoint(point)
        case .Ended:
            self.endAtPoint(point)
        case .Failed:
            self.endAtPoint(point)
        default:
            assert(false, "State not handled")
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(sender.view)
        if sender.state == .Ended {
            self.tapAtPoint(point)
        }
    }
    
    // MARK: Draw commands
    
    private func startAtPoint(point: CGPoint) {
        self.lastPoint = point
    }
    
    private func continueAtPoint(point: CGPoint) {
        let lineCommand = LineDrawCommand(a: self.lastPoint, b: point, width: self.width, color: self.color)
        
        self.canvas.executeCommand(lineCommand)
        self.commandQueue.append(lineCommand)
        
        self.lastPoint = point
    }
    
    private func endAtPoint(point: CGPoint) {
        self.lastPoint = CGPointZero
    }
    
    private func tapAtPoint(point: CGPoint) {
        let circleCommand = CircleDrawCommand(center: point, radius: self.width/2.0, color: self.color)
        self.canvas.executeCommand(circleCommand)
        self.commandQueue.append(circleCommand)
    }
    
    private let canvas: protocol<Canvas, DrawCommandReceiver>
    private var commandQueue: Array<DrawCommand> = []
    private var lastPoint: CGPoint = CGPointZero
}
