/*
The MIT License (MIT)

Copyright (c) 2015-present Badoo Trading Limited.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import UIKit

class DrawView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupGestureRecognizers()
    }
    
    // MARK: Drawing a path
    
    private func drawLine(a: CGPoint, b: CGPoint, buffer: UIImage?) -> UIImage {
        let image = drawInContext { context in
            // Draw the line
            self.drawColor.setStroke()
            CGContextSetLineWidth(context, self.drawWidth)
            CGContextSetLineCap(context, kCGLineCapRound)
            
            CGContextMoveToPoint(context, a.x, a.y)
            CGContextAddLineToPoint(context, b.x, b.y)
            CGContextStrokePath(context)
        }
        
        return image
    }
    
    // MARK: Drawing a point
    
    private func drawPoint(at: CGPoint, buffer: UIImage?) -> UIImage {
        let image = drawInContext { context in
            // Draw the point
            self.drawColor.setFill()
            let circle = UIBezierPath(arcCenter: at, radius: self.drawWidth / 2.0, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: true)
            circle.fill()
        }
        
        return image
    }
    
    // MARK: General setup to draw. Reusing a buffer and returning a new one
    
    private func drawInContext(code:(context: CGContextRef) -> Void) -> UIImage {
        let size = self.bounds.size
        
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor ?? UIColor.whiteColor().CGColor)
        CGContextFillRect(context, self.bounds)
        
        // Draw previous buffer first
        if let buffer = buffer {
            buffer.drawInRect(self.bounds)
        }
    
        // Execute draw code
        code(context: context)
        
        // Grab updated buffer and return it
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: Gestures
    
    private func setupGestureRecognizers() {
        // Pan gesture recognizer to track lines
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.addGestureRecognizer(panRecognizer)
        
        // Tap gesture recognizer to track points
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(self)
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
        let point = sender.locationInView(self)
        if sender.state == .Ended {
            self.tapAtPoint(point)
        }
    }
    
    // MARK: Tracing a line
    
    private func startAtPoint(point: CGPoint) {
        self.lastPoint = point
    }
    
    private func continueAtPoint(point: CGPoint) {
        autoreleasepool {
            // Draw the current stroke in an accumulated bitmap
            // Then replace layer contents with the updated image
            self.buffer = self.drawLine(self.lastPoint, b: point, buffer: self.buffer)
            self.layer.contents = self.buffer?.CGImage ?? nil
            
            self.lastPoint = point
        }
    }
    
    private func endAtPoint(point: CGPoint) {
        self.lastPoint = CGPointZero
    }
    
    // MARK: Tracking a point
    
    private func tapAtPoint(point: CGPoint) {
        autoreleasepool {
            self.buffer = self.drawPoint(point, buffer: self.buffer)
            self.layer.contents = self.buffer?.CGImage ?? nil
        }
    }
    
    var drawColor: UIColor = UIColor.blackColor()
    var drawWidth: CGFloat = 10.0
    
    private var lastPoint: CGPoint = CGPointZero
    private var buffer: UIImage?
}
