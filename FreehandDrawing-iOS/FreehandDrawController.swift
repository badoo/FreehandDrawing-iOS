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
    
    // MARK: API
    
    func undo() {
        if self.commandQueue.count > 0{
            self.commandQueue.removeLast()
            self.canvas.reset()
            self.canvas.executeCommands(self.commandQueue)
        }
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
            self.continueAtPoint(point, velocity: sender.velocityInView(sender.view))
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
        self.lineStrokeCommand = ComposedCommand(commands: [])
    }
    
    private func continueAtPoint(point: CGPoint, velocity: CGPoint) {
        let segmentWidth = modulatedWidth(self.width, velocity)
        let segment = Segment(a: self.lastPoint, b: point, width: segmentWidth)
        
        let lineCommand = LineDrawCommand(current: segment, previous: lastSegment, width: segmentWidth, color: self.color)
        
        self.canvas.executeCommands([lineCommand])

        self.lineStrokeCommand?.addCommand(lineCommand)
        self.lastPoint = point
        self.lastSegment = segment
    }
    
    private func endAtPoint(point: CGPoint) {
        if let lineStrokeCommand = self.lineStrokeCommand {
            self.commandQueue.append(lineStrokeCommand)
        }
        
        self.lastPoint = CGPointZero
        self.lastSegment = nil
        self.lineStrokeCommand = nil
    }
    
    private func tapAtPoint(point: CGPoint) {
        let circleCommand = CircleDrawCommand(center: point, radius: self.width/2.0, color: self.color)
        self.canvas.executeCommands([circleCommand])
        self.commandQueue.append(circleCommand)
    }
    
    private let canvas: protocol<Canvas, DrawCommandReceiver>
    private var lineStrokeCommand: ComposedCommand?
    private var commandQueue: Array<DrawCommand> = []
    private var lastPoint: CGPoint = CGPointZero
    private var lastSegment: Segment?
}
