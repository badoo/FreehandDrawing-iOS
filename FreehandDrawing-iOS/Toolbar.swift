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

class Toolbar : UIView {
    typealias ColorChangeHandler = UIColor -> Void
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Allows embedding a view in another xib or storyboard
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        if self.subviews.count > 0 {
            return self;
        }
        
        let mainBundle = NSBundle.mainBundle()
        let loadedView: UIView = mainBundle.loadNibNamed("Toolbar", owner: nil, options: nil).first! as! UIView
        
        loadedView.frame = self.frame;
        loadedView.autoresizingMask = self.autoresizingMask;
        loadedView.setTranslatesAutoresizingMaskIntoConstraints(self.translatesAutoresizingMaskIntoConstraints())
        
        for constraint in self.constraints() as! [NSLayoutConstraint] {
            let firstItem: AnyObject = constraint.firstItem as! NSObject == self ? loadedView : constraint.firstItem
            
            
            let secondItem: AnyObject?
            if let item = constraint.secondItem as? NSObject {
                secondItem = item == self ? loadedView : item
            } else {
                secondItem = nil
            }
    
            let newConstraint = NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
            
            loadedView.addConstraint(newConstraint)
        }
        
        return loadedView;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add a tap gesture recognizer for every view
        let addTapRecognizer = { (view: UIView) -> UIView in
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
            view.addGestureRecognizer(tapRecognizer)
            return view
        }
        
        let colorSelectors: [UIView] = [self.color1, self.color2, self.color3]
        
        colorSelectors.map(addTapRecognizer)
        colorSelectors.map { $0.layer.cornerRadius = CGRectGetWidth($0.frame) / 2.0 }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.colorChangeHandler?(sender.view?.backgroundColor ?? UIColor.blackColor())
        }
    }
    
    var colorChangeHandler: ColorChangeHandler?
    
    
    @IBOutlet var color1: UIView!
    @IBOutlet var color2: UIView!
    @IBOutlet var color3: UIView!
}

