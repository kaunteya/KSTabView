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
        tabView.pushButtonLeft("reload", title: "Reload")
        tabView.pushButtonLeft("twitterL", image: NSImage(named: "twitter.png")!, alternateImage: nil)
    }
    
    @IBAction func leftClean(sender: AnyObject) {
        tabView.removeLeftButtons()
    }

    @IBAction func addRight(sender: AnyObject) {
        tabView.removeRightButtons()
            .pushButtonRight("facebook", title: "Facebook", image: NSImage(named: "facebook.png")!, alternateImage: NSImage(named: "altFacebook.png")!)
            .pushButtonRight("google", image: NSImage(named: "google.png")!, alternateImage: nil)
            .pushButtonRight("instagram", title: "Instagram")
            .pushButtonRight("twitter", title: "Twitter", image: NSImage(named: "twitter.png")!, alternateImage: nil).selectedButtons = ["instagram"]
        
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
