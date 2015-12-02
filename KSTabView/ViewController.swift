//
//  ViewController.swift
//  KSTabView
//
//  Created by Kaunteya Suryawanshi on 13/06/15.
//  Copyright (c) 2015 com.kaunteya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tabView: KSTabView!

    @IBAction func selectionTypeChanged(sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0: tabView.selectionType = .None
        case 1: tabView.selectionType = .One
        case 2: tabView.selectionType = .Many
        default: ()
        }
    }
    
    @IBAction func actionOccured(sender: NSString?) {
        print("\(sender) pressed")
    }
    
    @IBAction func addLeft(sender: AnyObject) {
        tabView.removeLeftButtons()
        tabView.appendItem("reload", title: "Reload", align: .Left)
        tabView.appendItem("find", title: "Find", align: .Left)
    }
    
    @IBAction func leftClean(sender: AnyObject) {
        tabView.removeLeftButtons()
    }

    @IBAction func addRight(sender: NSSegmentedControl) {
        tabView.imagePositionRightButtonList = NSCellImagePosition(rawValue: UInt(sender.selectedSegment))!

        tabView.removeRightButtons()

        tabView.appendItem("facebook", title: "Facebook", image: NSImage(named: "facebook")!, alternateImage: NSImage(named: "altFacebook")!, align: .Right)
        tabView.appendItem("google", title: "Google", image: NSImage(named: "google")!, align: .Right)
        tabView.appendItem("instagram", title: "Instagram", image: NSImage(named: "instagram")!, align: .Right)
        tabView.appendItem("twitter", title: "Twitter", image: NSImage(named: "twitter")!, align: .Right)
    }
    
    @IBAction func rightClean(sender: AnyObject) {
        tabView.removeRightButtons()
    }

    @IBAction func selectMultiple(sender: NSButton) {
        tabView.selectedButtons = ["google", "twitter", "reload"]
    }

    @IBAction func selectOne(sender: NSButton) {
        tabView.selectedButtons = ["instagram", ]
    }

    @IBAction func clearSelection(sender: NSButton) {
        tabView.selectedButtons = []
    }
}
