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
        tabView.selectionType = KSTabView.SelectionType(rawValue: sender.selectedSegment)!
    }
    
    @IBAction func actionOccured(sender: NSString?) {
        println("\(sender) pressed")
    }
    
    @IBAction func addLeft(sender: AnyObject) {
        tabView.removeLeftButtons()
        tabView.pushButtonLeft("Reload", identifier: "reload", image: nil)
        tabView.pushButtonLeft("Jump", identifier: "jump", image: nil)
        tabView.selectedButtons = ["jump"]
    }
    
    @IBAction func leftClean(sender: AnyObject) {
        tabView.removeLeftButtons()
    }

    @IBAction func addRight(sender: AnyObject) {
        tabView.removeRightButtons()
        .pushButtonRight("Facebook", identifier: "facebook", image: NSImage(named: "facebook.png"))
            .pushButtonRight("Google", identifier: "google", image: nil)//NSImage(named: "google.png")
            .pushButtonRight("", identifier: "instagram", image: NSImage(named: "instagram.png"))
            .pushButtonRight("Twitter", identifier: "twitter", image: NSImage(named: "twitter.png")).selectedButtons = ["new"]
    }
    @IBAction func rightClean(sender: AnyObject) {
        tabView.removeRightButtons()
    }

    @IBAction func selectMultiple(sender: NSButton) {
        tabView.selectedButtons = ["google", "twitter", "jump"]
    }

    @IBAction func selectOne(sender: NSButton) {
        tabView.selectedButtons = ["delete", ]
    }

    @IBAction func clearSelection(sender: NSButton) {
        tabView.selectedButtons = []
    }
}
