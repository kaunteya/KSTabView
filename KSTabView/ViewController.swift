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

    @IBAction func addLeft(sender: AnyObject) {
        tabView.removeLeftButtons()
        tabView.addButtonsLeft(["Reload": "reload", "Jump": "jump"])
    }
    @IBAction func addRight(sender: AnyObject) {
        tabView.removeRightButtons()
        tabView.addButtonsRight(["Name": "name", "Age": "age"])
    }
    @IBAction func leftClean(sender: AnyObject) {
        tabView.removeLeftButtons()
    }
    
    @IBAction func rightClean(sender: AnyObject) {
        tabView.removeRightButtons()
    }


}

