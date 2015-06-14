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

    @IBAction func actionOccured(sender: NSString?) {
        println("\(sender) pressed")
    }
    
    @IBAction func addLeft(sender: AnyObject) {
        tabView.removeLeftButtons()
        tabView.pushButtonLeft("Reload", identifier: "reload")
        tabView.pushButtonLeft("Jump", identifier: "jump")
        tabView.selected = "jump"
    }

    @IBAction func addRight(sender: AnyObject) {
        tabView.removeRightButtons()
            .pushButtonRight("Name", identifier: "name")
            .pushButtonRight("Age", identifier: "age")
            .pushButtonRight("Gender", identifier: "gender")
            .pushButtonRight("Location", identifier: "location").selected = "gender"
    }
    @IBAction func leftClean(sender: AnyObject) {
        tabView.removeLeftButtons()
    }
    
    @IBAction func rightClean(sender: AnyObject) {
        tabView.removeRightButtons()
    }

    @IBAction func setSelected(sender: NSButton) {
        tabView.selected = "age"
    }
    
    @IBAction func clearSelection(sender: NSButton) {
        tabView.selected = nil
    }
}
