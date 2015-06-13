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
    static var backgroundColor: NSColor! = NSColor(calibratedRed: 5 / 255, green: 105 / 255, blue: 92 / 255, alpha: 1)
    static var hoverColor: NSColor! = NSColor(calibratedRed: 5 / 255, green: 105 / 255, blue: 92 / 255, alpha: 1).colorWithAlphaComponent(0.8)
    static var titleColor: NSColor! = NSColor(calibratedRed: 137/255, green: 185/255, blue: 175/255, alpha: 1.0)
    static var selectionColor: NSColor! = NSColor.whiteColor()

    var leftButtonList = [KSButton]()
    var rightButtonList = [KSButton]()
    var currentButton: KSButton? {
        didSet {
            if let _ = currentButton {
                oldValue?.setSelected(false)
                currentButton!.setSelected(true)
                if underlineView.hidden {
                    underlineView.hidden = false
                }
                self.setUnderScoreBelow(currentButton!)
            } else {
                underlineView.hidden = true
            }
        }
    }
    var underlineView: UnderLineView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        underlineView = UnderLineView(frame: NSZeroRect)
        underlineView.frame.size = NSMakeSize(0, 4)
        self.addSubview(underlineView)
    }
    
    func setUnderScoreBelow(button: NSButton) {
        let oldLocation = underlineView.frame.origin
        underlineView.frame.origin.x = button.frame.origin.x
        
        let oldSize = underlineView.frame.size
        underlineView.frame.size.width = button.frame.width
    }
    
    override func drawRect(dirtyRect: NSRect) {
        KSTabView.backgroundColor.setFill()
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
        for (title, identifier) in left {
            _pushButton(title, identifier: identifier, align: .Left)
        }
        underlineView.bringToFront()
    }
    
    func addButtonsRight(right: [String: String?]) {
        for (title, identifier) in right {
            _pushButton(title, identifier: identifier, align: .Right)
        }
        underlineView.bringToFront()
    }
    
    func _pushButton(title: String, identifier: String?, align: NSLayoutAttribute) {
        var button = KSButton(title, identifier)
        button.target = self
        button.action = "buttonPressed:"
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        
        var formatString: String!
        var viewsDictionary: [String: AnyObject]!
        
        if align == NSLayoutAttribute.Right {
            if let rightButton = rightButtonList.first {
                viewsDictionary = ["button" : button, "rightButton" : rightButton]
                formatString = "H:[button(size)]-[rightButton]"
            } else {
                viewsDictionary = ["button": button]
                formatString = "H:[button(size)]|"
            }
            rightButtonList.append(button)
        } else if align == NSLayoutAttribute.Left {
            if let leftButton = leftButtonList.last {
                viewsDictionary = ["button" : button, "leftButton" : leftButton]
                formatString = "H:[leftButton]-[button(size)]"
            } else {
                viewsDictionary = ["button": button]
                formatString = "H:|[button(size)]"
            }
            leftButtonList.append(button)
        }
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                formatString,
                options: NSLayoutFormatOptions(0),
                metrics: ["size": button.frame.size.width + 20],
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
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            boxType = NSBoxType.Custom
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
    }
}

//MARK: KSButton
class KSButton: NSButton {
    var trackingArea: NSTrackingArea!

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways, owner: self, userInfo: nil)
        }
        self.addTrackingArea(trackingArea)
    }
    
    func setSelected(isIt: Bool) {
        let color = isIt ? KSTabView.selectionColor : KSTabView.titleColor
        self.attributedTitle = attributedString(color)
    }
    
    init(_ title: String, _ identifier: String?) {
        super.init(frame: NSZeroRect)
        self.title = title
        self.identifier = identifier
        self.attributedTitle = attributedString(KSTabView.titleColor)
        (self.cell() as! NSButtonCell).bordered = false
        self.sizeToFit()
    }
    
    func attributedString(color: NSColor) -> NSAttributedString {
        let font = NSFont.labelFontOfSize(18)
        var colorTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
        
        var titleRange = NSMakeRange(0, colorTitle.length)
        colorTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: titleRange)
        colorTitle.addAttribute(NSFontAttributeName, value: font, range: titleRange)
        return colorTitle
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.attributedTitle = attributedString(KSTabView.titleColor)
        
        (self.cell() as! NSButtonCell).bordered = false
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        (self.cell() as! NSButtonCell).backgroundColor = KSTabView.hoverColor
    }
    
    override func mouseExited(theEvent: NSEvent) {
        (self.cell() as! NSButtonCell).backgroundColor = KSTabView.backgroundColor
    }
}

