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

    @IBAction func selectionTypeChanged(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0: tabView.selectionType = .none
        case 1: tabView.selectionType = .one
        case 2: tabView.selectionType = .many
        default: ()
        }
    }
    
    @IBAction func actionOccured(_ sender: NSString?) {
        print("\(sender) pressed")
    }
    
    @IBAction func addLeft(_ sender: AnyObject) {
        tabView.removeLeftButtons()
        tabView.appendItem("reload", title: "Reload", align: .left)
        tabView.appendItem("find", title: "Find", align: .left)
    }
    
    @IBAction func leftClean(_ sender: AnyObject) {
        tabView.removeLeftButtons()
    }

    @IBAction func addRight(_ sender: NSSegmentedControl) {
        tabView.imagePositionRightButtonList = NSCellImagePosition(rawValue: UInt(sender.selectedSegment))!

        tabView.removeRightButtons()

        tabView.appendItem("facebook", title: "Facebook", image: NSImage(named: "facebook")!, alternateImage: NSImage(named: "altFacebook")!, align: .right)
        tabView.appendItem("google", title: "Google", image: NSImage(named: "google")!, align: .right)
        tabView.appendItem("instagram", title: "Instagram", image: NSImage(named: "instagram")!, align: .right)
        tabView.appendItem("twitter", title: "Twitter", image: NSImage(named: "twitter")!, align: .right)
    }
    
    @IBAction func rightClean(_ sender: AnyObject) {
        tabView.removeRightButtons()
    }

    @IBAction func selectMultiple(_ sender: NSButton) {
        tabView.selectedButtons = ["google", "twitter", "reload"]
    }

    @IBAction func selectOne(_ sender: NSButton) {
        tabView.selectedButtons = ["instagram", ]
    }

    @IBAction func clearSelection(_ sender: NSButton) {
        tabView.selectedButtons = []
    }

    @IBAction func logSelection(_ sender: NSButton) {
        Swift.print(tabView.selectedButtons)
    }

}
