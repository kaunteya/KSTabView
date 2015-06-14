//
//  KSTabController.swift
//  KSTabView
//
//  Created by Kaunteya Suryawanshi on 13/06/15.
//  Copyright (c) 2015 com.kaunteya. All rights reserved.
//

import Foundation
import Cocoa

class KSTabView: NSControl {
    @IBInspectable var backgroundColor: NSColor! = NSColor(calibratedRed: 5 / 255, green: 105 / 255, blue: 92 / 255, alpha: 1)
    @IBInspectable var hoverColor: NSColor! = NSColor(calibratedRed: 5 / 255, green: 105 / 255, blue: 92 / 255, alpha: 1).colorWithAlphaComponent(0.8)
    @IBInspectable var titleColor: NSColor! = NSColor(calibratedRed: 137/255, green: 185/255, blue: 175/255, alpha: 1.0)
    @IBInspectable var selectionColor: NSColor! = NSColor.whiteColor()
    
    @IBInspectable var fontSize: CGFloat = 16
    @IBInspectable var buttonPadding: CGFloat = 20
    
    var leftButtonList = [KSButton]()
    var rightButtonList = [KSButton]()
    var currentButton: KSButton? {
        didSet {
            oldValue?.setSelected(false)
            currentButton?.setSelected(true)
            underlineView.setForButton(currentButton)
        }
    }

    var selected: String? {
        get {
            return currentButton?.identifier
        }
        set(newIdentifier) {
            currentButton = (leftButtonList + rightButtonList).filter { $0.identifier == newIdentifier }.first as KSButton?
        }
    }

    var underlineView: UnderLineView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        underlineView = UnderLineView(height: 3)
        self.addSubview(underlineView)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.CompositeSourceOver)
    }
    
    func removeLeftButtons() {
        for aButton in leftButtonList {
            aButton.removeFromSuperview()
            if aButton === currentButton {
                currentButton = nil
            }
        }
        leftButtonList.removeAll(keepCapacity: false)
        
    }
    func removeRightButtons() {
        for aButton in rightButtonList {
            aButton.removeFromSuperview()
            if aButton === currentButton {
                currentButton = nil
            }
        }
        rightButtonList.removeAll(keepCapacity: false)
        
    }
    
    func addButtonsLeft(left: [String: String?]) {
        removeLeftButtons()
        for (title, identifier) in left {
            _pushButton(title, identifier: identifier, align: .Left)
        }
        underlineView.bringToFront()
    }
    
    func addButtonsRight(right: [String: String?]) {
        removeRightButtons()
        for (title, identifier) in right {
            _pushButton(title, identifier: identifier, align: .Right)
        }
        underlineView.bringToFront()
    }
    
    func _pushButton(title: String, identifier: String?, align: NSLayoutAttribute) {
        var button = KSButton(title, identifier, tabView: self)
        button.target = self
        button.action = "buttonPressed:"
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        
        var formatString: String!
        var viewsDictionary: [String: AnyObject]!
        if align == NSLayoutAttribute.Left {
            if let leftButton = leftButtonList.last {
                viewsDictionary = ["button" : button, "leftButton" : leftButton]
                formatString = "H:[leftButton][button(size)]"
            } else {
                viewsDictionary = ["button": button]
                formatString = "H:|[button(size)]"
            }
            leftButtonList.append(button)
        } else if align == NSLayoutAttribute.Right {
            if let rightButton = rightButtonList.last {
                viewsDictionary = ["button" : button, "rightButton" : rightButton]
                formatString = "H:[button(size)][rightButton]"
            } else {
                viewsDictionary = ["button": button]
                formatString = "H:[button(size)]|"
            }
            rightButtonList.append(button)
        }
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                formatString,
                options: NSLayoutFormatOptions(0),
                metrics: ["size": button.frame.size.width + buttonPadding],
                views: viewsDictionary)
        )
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[button(height)]",
                options: NSLayoutFormatOptions(0),
                metrics: ["height": self.frame.size.height],
                views: ["button" : button])
        )
    }
    
    func buttonPressed(sender: KSButton) {
        currentButton = sender
        NSApplication.sharedApplication().sendAction(self.action, to: self.target, from: sender)
    }
}

//MARK: KSButton
extension KSTabView {
    class UnderLineView: NSBox {

        init(height: CGFloat) {
            super.init(frame: NSMakeRect(0, 0, 0, height))
            boxType = NSBoxType.Custom
            borderWidth = 0
            fillColor = NSColor.whiteColor()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        func bringToFront() {
            if let superView = self.superview {
                self.removeFromSuperview()
                superView.addSubview(self)
            }
        }

        func setForButton(button: KSButton?) {
            if let button = button {
                self.hidden = false
                let oldLocation = self.frame.origin
                self.frame.origin.x = button.frame.origin.x
                
                let oldSize = self.frame.size
                self.frame.size.width = button.frame.width
            } else {
                self.hidden = true
            }
        }
    }
}

//MARK: KSButton
extension KSTabView {
    class KSButton: NSButton {
        var trackingArea: NSTrackingArea!
        let parentTabView: KSTabView
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if trackingArea != nil {
                self.removeTrackingArea(trackingArea)
            }
            trackingArea = NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways, owner: self, userInfo: nil)
            self.addTrackingArea(trackingArea)
        }
        
        func setSelected(isIt: Bool) {
            let color = isIt ? parentTabView.selectionColor : parentTabView.titleColor
            self.attributedTitle = attributedString(color)
        }
        
        init(_ title: String, _ identifier: String?, tabView: KSTabView) {
            parentTabView = tabView
            super.init(frame: NSZeroRect)
            self.title = title
            self.identifier = identifier
            self.attributedTitle = attributedString(parentTabView.titleColor)
            (self.cell() as! NSButtonCell).bordered = false
            self.sizeToFit()
        }
        
        func attributedString(color: NSColor) -> NSAttributedString {
            let font = NSFont.labelFontOfSize(parentTabView.fontSize)
            var colorTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
            
            var titleRange = NSMakeRange(0, colorTitle.length)
            colorTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: titleRange)
            colorTitle.addAttribute(NSFontAttributeName, value: font, range: titleRange)
            return colorTitle
        }
        
        required init?(coder: NSCoder) {
            parentTabView =  NSView(frame: NSZeroRect) as! KSTabView
            super.init(coder: coder)
            
            self.attributedTitle = attributedString(parentTabView.titleColor)
            
            (self.cell() as! NSButtonCell).bordered = false
        }
        
        override func mouseEntered(theEvent: NSEvent) {
            (self.cell() as! NSButtonCell).backgroundColor = parentTabView.hoverColor
        }
        
        override func mouseExited(theEvent: NSEvent) {
            (self.cell() as! NSButtonCell).backgroundColor = parentTabView.backgroundColor
        }
    }
}
