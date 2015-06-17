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
    @IBInspectable var buttonPadding: CGFloat = 10
    
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
    
    public func pushButtonLeft(identifier: String, title: String) -> KSTabView {
        _pushButton(identifier, title: title, image: nil, alternateImage: nil, align: .Left)
        return self
    }
    
    public func pushButtonLeft(identifier: String, image: NSImage, alternateImage: NSImage?) -> KSTabView {
        _pushButton(identifier, title: nil, image: image, alternateImage: alternateImage, align: .Left)
        return self
    }
    public func pushButtonLeft(identifier: String, title: String, image: NSImage, alternateImage: NSImage?) -> KSTabView {
        _pushButton(identifier, title: title, image: image, alternateImage: alternateImage, align: .Left)
        return self
    }

    public func pushButtonRight(identifier: String, title: String) -> KSTabView {
        _pushButton(identifier, title: title, image: nil, alternateImage: nil, align: .Right)
        return self
    }
    
    public func pushButtonRight(identifier: String, image: NSImage, alternateImage: NSImage?) -> KSTabView {
        _pushButton(identifier, title: nil, image: image, alternateImage: alternateImage, align: .Right)
        return self
    }

    public func pushButtonRight(identifier: String, title: String, image: NSImage, alternateImage: NSImage?) -> KSTabView {
        _pushButton(identifier, title: title, image: image, alternateImage: alternateImage, align: .Right)
        return self
    }
    
    private func _pushButton(identifier: String, title: String?, image: NSImage?, alternateImage: NSImage?, align: NSLayoutAttribute) {
        
        
        var button = KSButton(identifier, title, image, alternateImage, tabView: self)
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
            if sender.selected {
                self.selectedButtons = self.selectedButtons.filter{ $0 != sender.identifier }
            } else {
                self.selectedButtons.append(sender.identifier!)
            }
        default:()
        }
        
        NSApplication.sharedApplication().sendAction(self.action, to: self.target, from: sender.identifier as NSString?)
    }
}

//MARK: KSButton
extension KSTabView {
    class KSButton: NSControl {

        private let parentTabView: KSTabView
        private var mouseInside = false {
            didSet {
                self.needsDisplay = true
            }
        }
        private var underline: UnderLine!
        private let selectionLineHeight = CGFloat(3)
        
        var button: NSButton!

        var selected = false {
            didSet {
                println("\(self.identifier) selected \(selected)")
                let activeColor = self.selected ? parentTabView.selectionColor : parentTabView.labelColor
                button.setAttributedString(parentTabView.fontSize, color: activeColor)
                button.state = self.selected ? NSOnState : NSOffState
                underline.hidden = !self.selected
            }
        }
        
        var trackingArea: NSTrackingArea!
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if trackingArea != nil {
                self.removeTrackingArea(trackingArea)
            }
            trackingArea = NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways, owner: self, userInfo: nil)
            self.addTrackingArea(trackingArea)
        }
        
        init(_ identifier: String?, _ title: String?, _ image: NSImage?,_ alternateImage:NSImage?, tabView: KSTabView) {
            parentTabView = tabView
            super.init(frame: NSZeroRect)
            self.identifier = identifier
          
            button = NSButton.makeButton(title, image, alternateImage, tabView: tabView)
            self.addSubview(button)
            button.frame.origin = NSMakePoint(parentTabView.buttonPadding, selectionLineHeight)
            
            let frameWidth = button.frame.width + (parentTabView.buttonPadding * 2)
            
            /// UnderLine
            underline = UnderLine(frame: NSMakeRect(selectionLineHeight, 0, frameWidth - (selectionLineHeight * 2), selectionLineHeight))
            self.addSubview(underline)
            
            /// Frame Size
            self.frame.size = NSMakeSize(frameWidth, NSHeight(parentTabView.frame))
            
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

extension NSButton {
    private class ButtonCell: NSButtonCell {
        override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
            return super.drawTitle(self.attributedTitle, withFrame: frame, inView: controlView)
        }
    }
    
    func setAttributedString(fontSize: CGFloat, color: NSColor) {
        let font = NSFont.labelFontOfSize(fontSize)
        var colorTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
        
        var titleRange = NSMakeRange(0, colorTitle.length)
        colorTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: titleRange)
        colorTitle.addAttribute(NSFontAttributeName, value: font, range: titleRange)
        self.attributedTitle = colorTitle
    }

    class func makeButton(title: String?, _ image: NSImage?,_ alternateImage: NSImage?, tabView: KSTabView)  -> NSButton {
        var button = NSButton(frame: NSZeroRect)
        button.setCell(ButtonCell())
        button.imagePosition = NSCellImagePosition.ImageLeft
        button.setButtonType(NSButtonType.ToggleButton)
        button.bordered = false
        button.enabled = false
        
        button.title = title ?? ""
        
        button.image = image
        button.image?.size = NSMakeSize(tabView.fontSize * 1.7, tabView.fontSize * 1.7)
        
        button.alternateImage = alternateImage
        button.alternateImage?.size = NSMakeSize(tabView.fontSize * 1.7, tabView.fontSize * 1.7)
        
        button.setAttributedString(tabView.fontSize, color: tabView.labelColor)
        button.sizeToFit()
        button.frame.size.height = tabView.fontSize * 1.7
        return button
    }
}

extension KSTabView.KSButton {
    private class UnderLine: NSBox {
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.boxType = NSBoxType.Custom
            self.borderWidth = 0
            self.fillColor = NSColor.whiteColor()
            self.hidden = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) invalid")
        }
    }
}
