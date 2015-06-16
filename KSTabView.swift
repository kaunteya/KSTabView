//
//  KSTabController.swift
//  KSTabView
//
//  Created by Kaunteya Suryawanshi on 13/06/15.
//  Copyright (c) 2015 com.kaunteya. All rights reserved.
//

import Foundation
import Cocoa

public class KSTabView: NSControl {
    
    enum SelectionType: Int {
        case None =  0, One, Any
    }
    
    @IBInspectable var backgroundColor: NSColor! = NSColor(calibratedRed: 5 / 255, green: 105 / 255, blue: 92 / 255, alpha: 1)
    @IBInspectable var hoverColor: NSColor! = NSColor(calibratedRed: 12 / 255, green: 81 / 255, blue: 68 / 255, alpha: 1)
    
    @IBInspectable var labelColor: NSColor! = NSColor(calibratedRed: 137/255, green: 185/255, blue: 175/255, alpha: 1.0)
    @IBInspectable var selectionColor: NSColor! = NSColor.whiteColor()
    
    @IBInspectable var fontSize: CGFloat = 16
    @IBInspectable var buttonPadding: CGFloat = 20
    
    var leftButtonList = [KSButton]()
    var rightButtonList = [KSButton]()
    
    var selectionType: SelectionType = .One {
        didSet {
            self.selectedButtons = []
        }
    }
    
    public var selectedButtons: [String] {
        get {
            return (leftButtonList + rightButtonList).filter { $0.selected }.map { $0.identifier }.filter{ $0 != nil}.map {$0!}
        }
        
        set(newIdentifierList) {
            
            switch selectionType {
            case .One:
                if newIdentifierList.count > 1 {
                    println("Only one button can be selected")
                    return
                }
            default:()
            }
            
            for button in (leftButtonList + rightButtonList) {
                if let validIdentifier = button.identifier where contains(newIdentifierList, validIdentifier) {
                    button.selected = true
                } else {
                    button.selected = false
                }
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.CompositeSourceOver)
    }
    
    public func removeLeftButtons() -> KSTabView {
        for aButton in leftButtonList {
            aButton.removeFromSuperview()
        }
        leftButtonList.removeAll(keepCapacity: false)
        return self
    }
    
    public func removeRightButtons() -> KSTabView {
        for aButton in rightButtonList {
            aButton.removeFromSuperview()
        }
        rightButtonList.removeAll(keepCapacity: false)
        return self
    }
    
    public func pushButtonLeft(title: String, identifier: String) -> KSTabView {
        _pushButton(title, identifier: identifier, align: .Left)
        return self
    }
    
    public func pushButtonRight(title: String, identifier: String) -> KSTabView {
        _pushButton(title, identifier: identifier, align: .Right)
        return self
    }
    
    private func _pushButton(title: String, identifier: String?, align: NSLayoutAttribute) {
        var button = KSButton(title, identifier, tabView: self)
        button.target = self
        button.action = "buttonPressed:"
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
                metrics: ["size": button.frame.size.width],
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
        switch selectionType {
        case .One:
            self.selectedButtons = [sender.identifier!]
        case .Any:
            self.selectedButtons.append(sender.identifier!)
        default:()
        }
        
        NSApplication.sharedApplication().sendAction(self.action, to: self.target, from: sender.identifier as NSString?)
    }
}

//MARK: KSButton
extension KSTabView {
    class KSButton: NSControl {
        var trackingArea: NSTrackingArea!
        private let parentTabView: KSTabView
        private var mouseInside = false {
            didSet {
                self.needsDisplay = true
            }
        }
        private var label: Label?
        private var image: NSImage?
        private var underline: UnderLine!
        private let selectionLineHeight = CGFloat(3)
        var selected = false {
            didSet {
                label?.textColor = self.selected ? parentTabView.selectionColor : parentTabView.labelColor
                underline.hidden = !self.selected
            }
        }
        
        func toggleSelection() {
            selected = !selected
        }
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if trackingArea != nil {
                self.removeTrackingArea(trackingArea)
            }
            trackingArea = NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways, owner: self, userInfo: nil)
            self.addTrackingArea(trackingArea)
        }
        
        init(_ title: String, _ identifier: String?, tabView: KSTabView) {
            parentTabView = tabView
            super.init(frame: NSZeroRect)

            self.identifier = identifier
            
            label = Label(title: title, color: parentTabView.labelColor)
            label?.frame.origin = NSMakePoint(parentTabView.buttonPadding / 2, selectionLineHeight + 2)
            self.addSubview(label!)
            
            
            self.frame.size = NSMakeSize(label!.attributedStringValue.size.width + parentTabView.buttonPadding, NSHeight(parentTabView.frame))
            
            underline = UnderLine()
            underline.frame.origin = NSMakePoint(selectionLineHeight, 0)
            underline.frame.size = NSMakeSize(self.frame.size.width - (selectionLineHeight * 2) + parentTabView.buttonPadding, selectionLineHeight)
            self.addSubview(underline)
        }
        
        
        required init?(coder: NSCoder) { fatalError("Init from IB not supported") }
        
        override func mouseEntered(theEvent: NSEvent) { mouseInside = true }
        
        override func mouseExited(theEvent: NSEvent) { mouseInside = false }
        
        override func mouseUp(theEvent: NSEvent) {
            NSApplication.sharedApplication().sendAction(self.action, to: self.target, from: self)

        }
        
        override func drawRect(dirtyRect: NSRect) {
            if mouseInside {
                parentTabView.hoverColor.setFill()
            } else {
                parentTabView.backgroundColor.setFill()
            }
            NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.CompositeSourceOver)
        }
    }
}

private class Label: NSTextField {
    init(title: String, color: NSColor) {
        super.init(frame: NSZeroRect)
        self.editable = false
        self.selectable = false
        self.stringValue = title
        self.textColor = color
        self.bordered = false
        self.backgroundColor = NSColor.clearColor()
        self.sizeToFit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class UnderLine: NSBox {
    init() {
        super.init(frame: NSZeroRect)
        self.boxType = NSBoxType.Custom
        self.borderWidth = 0
        self.fillColor = NSColor.whiteColor()
        self.hidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
