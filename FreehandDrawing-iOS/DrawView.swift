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
        
        // Draw the line
        self.drawColor.setStroke()
        CGContextSetLineWidth(context, self.drawWidth)
        CGContextSetLineCap(context, kCGLineCapRound)
        
        CGContextMoveToPoint(context, a.x, a.y)
        CGContextAddLineToPoint(context, b.x, b.y)
        CGContextStrokePath(context)
        
        // Grab the updated buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: Gestures
    
    private func setupGestureRecognizers() {
        // 1. Set up a pan gesture recognizer to track where user moves finger
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.addGestureRecognizer(panRecognizer)
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
    
    // MARK: Tracing a line
    
    private func startAtPoint(point: CGPoint) {
        self.lastPoint = point
    }
    
    private func continueAtPoint(point: CGPoint) {
        // 2. Draw the current stroke in an accumulated bitmap
        self.buffer = self.drawLine(self.lastPoint, b: point, buffer: self.buffer)
        
        // 3. Replace the layer contents with the updated image
        self.layer.contents = self.buffer?.CGImage ?? nil
        
        // 4. Update last point for next stroke
        self.lastPoint = point
    }
    
    private func endAtPoint(point: CGPoint) {
        self.lastPoint = CGPointZero
    }
    
    var drawColor: UIColor = UIColor.blackColor()
    var drawWidth: CGFloat = 10.0
    
    private var lastPoint: CGPoint = CGPointZero
    private var buffer: UIImage?
}
