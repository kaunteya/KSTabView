//
//  KSTabController.swift
//  KSTabView
//
//  Created by Kaunteya Suryawanshi on 13/06/15.
//  Copyright (c) 2015 com.kaunteya. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
open class KSTabView: NSControl {

    public enum SelectionType {
        case none, one, many
    }

    public enum AlignSide {
        case left, right
    }

    @IBInspectable var backgroundColor: NSColor! = NSColor(calibratedRed: 5 / 255, green: 105 / 255, blue: 92 / 255, alpha: 1)
    @IBInspectable var hoverColor: NSColor! = NSColor(calibratedRed: 12 / 255, green: 81 / 255, blue: 68 / 255, alpha: 1)

    @IBInspectable var labelColor: NSColor! = NSColor(calibratedRed: 137/255, green: 185/255, blue: 175/255, alpha: 1.0)
    @IBInspectable var selectionColor: NSColor! = NSColor.white

    @IBInspectable var underlineColor: NSColor! = NSColor.white
    
    @IBInspectable var fontSize: CGFloat = 16
    open var labelFont: NSFont = NSFont.labelFont(ofSize: 16) // wish this was @IBInspectable
    @IBInspectable var buttonPadding: CGFloat = 10

    fileprivate var leftButtonList = [KSButton]()
    fileprivate var rightButtonList = [KSButton]()

    // Default image position would be to left of Button Label
    open var imagePositionLeftButtonList = NSCellImagePosition.imageLeft
    open var imagePositionRightButtonList = NSCellImagePosition.imageLeft

    var selectionType: SelectionType = .one {
        didSet {
            // Selection Type change requires removal of all selected buttons
            self.selectedButtons = []
        }
    }

    open var selectedButtons: [String] {
        // Get the list of identifiers of selected buttons
        get {
            return (leftButtonList + rightButtonList).reduce([String]()) { (accum, each) in
                if each.selected {
                    return accum + [each.identifier!]
                } else {
                    return accum
                }
            }
        }

        set(newIdentifierList) {

            switch selectionType {
            case .one:
                if newIdentifierList.count > 1 {
                    Swift.print("Only one button can be selected")
                    return
                }
            default:()
            }

            for button in (leftButtonList + rightButtonList) {
                if let validIdentifier = button.identifier , newIdentifierList.contains(validIdentifier) {
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
    
    override open func awakeFromNib()
    {
        // if fontSize was changed via the inspector, make sure it's changed here too...
        if fontSize != 16.0
        {
            if let newFont = NSFont(name: self.labelFont.fontName, size: fontSize)
            {
                self.labelFont = newFont
            }
        }
    }
    override open func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
    }

    open func removeLeftButtons() -> KSTabView {
        for aButton in leftButtonList {
            aButton.removeFromSuperview()
        }
        leftButtonList.removeAll(keepingCapacity: false)
        return self
    }

    open func removeRightButtons() -> KSTabView {
        for aButton in rightButtonList {
            aButton.removeFromSuperview()
        }
        rightButtonList.removeAll(keepingCapacity: false)
        return self
    }

    open func appendItem(_ identifier: String, title: String? = nil,
        image: NSImage? = nil, alternateImage: NSImage? = nil,
        align: AlignSide = .left) {

            // Return if both title and image are nil at the same time
            guard title != nil && image != nil else {
                return
            }

            // Set all the parameters related to button
            let coreButton = NSButton(frame: NSZeroRect)
            coreButton.title = title ?? ""
            coreButton.identifier = identifier
            coreButton.image = image
            coreButton.alternateImage = alternateImage

            if image != nil {
                if align == .left {
                    coreButton.imagePosition = imagePositionLeftButtonList
                } else if align == .right {
                    coreButton.imagePosition = imagePositionRightButtonList
                }
            } else {
                coreButton.imagePosition = NSCellImagePosition.noImage
            }

            coreButton.updateButtonFortabView(self)

            // Core button is sent to KSButton for look and feel
            let button = KSButton(aButton: coreButton, tabView: self)
            self.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false

            var formatString: String!
            var viewsDictionary: [String: AnyObject]!
            if align == AlignSide.left {
                if let leftButton = leftButtonList.last {
                    viewsDictionary = ["button" : button, "leftButton" : leftButton]
                    formatString = "H:[leftButton][button(size)]"
                } else {
                    viewsDictionary = ["button": button]
                    formatString = "H:|[button(size)]"
                }
                leftButtonList.append(button)
            } else if align == AlignSide.right {
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
                NSLayoutConstraint.constraints(
                    withVisualFormat: formatString,
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: ["size": NSNumber(floatLiteral: Double(button.frame.size.width))],
                    views: viewsDictionary)
            )
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[button(height)]",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: ["height": NSNumber(floatLiteral: Double(button.frame.size.height))],
                    views: ["button" : button])
            )
    }

    func buttonPressed(_ sender: KSButton) {
        switch selectionType {
        case .one:
            self.selectedButtons = [sender.identifier!]
        case .many:
            if sender.selected {
                self.selectedButtons = self.selectedButtons.filter{ $0 != sender.identifier }
            } else {
                self.selectedButtons.append(sender.identifier!)
            }
        default:()
        }

        NSApplication.shared().sendAction(self.action!, to: self.target, from: sender.identifier as NSString?)
    }
}

//MARK: KSButton
extension KSTabView {

    /// KSButton is a wrapper to NSButton with added features like hover detection underline layer
    class KSButton: NSControl {

        fileprivate let parentTabView: KSTabView
        fileprivate var mouseInside = false {
            didSet {
                self.needsDisplay = true
            }
        }
        var underLayer = CAShapeLayer()
        fileprivate let selectionLineHeight: CGFloat

        fileprivate var button: NSButton!

        var selected = false {
            didSet {
                let activeColor = self.selected ? parentTabView.selectionColor : parentTabView.labelColor
                button.setAttributedString(parentTabView.labelFont, color: activeColor!)
                button.state = self.selected ? NSOnState : NSOffState

                CATransaction.begin()
                if self.selected {
                    CATransaction.setAnimationDuration(0.5)
                } else {
                    CATransaction.setDisableActions(true)
                }
                let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                CATransaction.setAnimationTimingFunction(timing)
                underLayer.strokeStart = 0
                underLayer.strokeEnd =  self.selected ? 1 : 0
                CATransaction.commit()
            }
        }

        var trackingArea: NSTrackingArea!
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if trackingArea != nil {
                self.removeTrackingArea(trackingArea)
            }
            trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: nil)
            self.addTrackingArea(trackingArea)
        }

        init(aButton: NSButton, tabView: KSTabView) {
            parentTabView = tabView
            selectionLineHeight = parentTabView.labelFont.pointSize / 5

            super.init(frame: NSZeroRect)
            self.wantsLayer = true
            self.identifier = aButton.identifier
            self.button = aButton
            self.target = tabView
            self.action = #selector(buttonPressed)
            self.addSubview(self.button)
            self.button.frame.origin = NSMakePoint(parentTabView.buttonPadding, selectionLineHeight * 1.5)

            let frameWidth = self.button.frame.width + (parentTabView.buttonPadding * 2)

            makeUnderLayer(frameWidth)

            let frameHeight = tabView.labelFont.pointSize * 3.0
            self.frame.size = NSSize(width: frameWidth, height: frameHeight)
        }

        func makeUnderLayer(_ frameWidth: CGFloat) {
            let path = NSBezierPath()
            path.move(to: NSMakePoint(selectionLineHeight, 2))
            path.line(to: NSMakePoint(frameWidth - selectionLineHeight, 2))
            underLayer.path = path.CGPath
            underLayer.strokeEnd = 0
            underLayer.lineWidth = selectionLineHeight
            underLayer.strokeColor = parentTabView.underlineColor.cgColor
            self.layer!.addSublayer(underLayer)
        }

        required init?(coder: NSCoder) { fatalError("Init from IB not supported") }

        override func mouseEntered(with theEvent: NSEvent) { mouseInside = true }

        override func mouseExited(with theEvent: NSEvent) { mouseInside = false }

        override func mouseUp(with theEvent: NSEvent) {
            NSApplication.shared().sendAction(self.action!, to: self.target, from: self)
        }

        override func draw(_ dirtyRect: NSRect) {
            if mouseInside {
                parentTabView.hoverColor.setFill()
            } else {
                parentTabView.backgroundColor.setFill()
            }
            NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
        }
    }
}

extension NSButton {

    fileprivate class ButtonCell: NSButtonCell {
        init(title: String, cellImage: NSImage?) {
            super.init(imageCell: cellImage)
            self.title = title
            self.imageDimsWhenDisabled = false
        }

        required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        // To set title of the button to attributed string
        override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
            return super.drawTitle(self.attributedTitle, withFrame: frame, in: controlView)
        }
    }

    func setAttributedString(_ font: NSFont, color: NSColor) {
        let colorTitle = NSMutableAttributedString(attributedString: self.attributedTitle)

        let titleRange = NSMakeRange(0, colorTitle.length)
        colorTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: titleRange)
        colorTitle.addAttribute(NSFontAttributeName, value: font, range: titleRange)
        self.attributedTitle = colorTitle
    }

    /// Updates the look and feel of button as per KSTabView
    func updateButtonFortabView(_ tabView: KSTabView){
        let oldImagePosition = self.imagePosition
        self.setButtonType(NSButtonType.toggle)

        self.cell = ButtonCell(title: self.title, cellImage: self.image)
        self.imagePosition = oldImagePosition
        self.isBordered = false
        self.isEnabled = false
        self.image?.size = NSMakeSize(tabView.labelFont.pointSize * 1.7, tabView.labelFont.pointSize * 1.7)
        self.alternateImage?.size = NSMakeSize(tabView.labelFont.pointSize * 1.7, tabView.labelFont.pointSize * 1.7)

        self.setAttributedString(tabView.labelFont, color: tabView.labelColor)
        self.sizeToFit()
    }
}

extension NSBezierPath {
    /// Converts NSBezierPath to CGPath
    var CGPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let numElements = self.elementCount

        for index in 0..<numElements {
            let pathType = self.element(at: index, associatedPoints: points)
            switch pathType {
            case .moveToBezierPathElement:
                path.move(to: points[0])
            case .lineToBezierPathElement:
                path.addLine(to: points[0])
            case .curveToBezierPathElement:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement:
                path.closeSubpath()
            }
        }

        points.deallocate(capacity: 3)
        return path
    }
}

