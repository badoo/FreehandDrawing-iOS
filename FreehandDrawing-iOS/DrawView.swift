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
    
    override func drawRect(rect: CGRect) {
        // 4. Redraw whole rect, ignoring parameter. Please note we always invalidate whole view.
        let context = UIGraphicsGetCurrentContext()
        self.drawColor.setStroke()
        self.path.lineWidth = self.drawWidth
        self.path.lineCapStyle = kCGLineCapRound
        self.path.stroke()
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
        self.path.moveToPoint(point)
    }
    
    private func continueAtPoint(point: CGPoint) {
        // 2. Accumulate points as they are reported by the gesture recognizer, in a bezier path object
        self.path.addLineToPoint(point)
        
        // 3. Trigger a redraw every time a point is added (finger moves)
        self.setNeedsDisplay()
    }
    
    private func endAtPoint(point: CGPoint) {
        // Nothing to do when ending/cancelling for now
    }
    
    var drawColor: UIColor = UIColor.blackColor()
    var drawWidth: CGFloat = 10.0
    
    private var path: UIBezierPath = UIBezierPath()
}
