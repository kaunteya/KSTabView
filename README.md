#KSTabView

`KSTabView` is simple TabView for Mac OSX implemented in Swift
![](./demo.png)


## Requirements

- Mac OS X 10.10+
- Xcode 6.3

##Usage
####Setup
Drag `KSTabView.swift` to you project.

In IB, drag a Custom View from Object Library. Change Class to KSTabView

Drag IBOutlet to ViewController
```swift
@IBOutlet weak var tabView: KSTabView!
```
####Adding buttons
Buttons can be pushed to left or right side
```swift
tabView.pushButtonLeft("Reload", identifier: "reload")
tabView.pushButtonRight("Jump", identifier: "jump")
```
Identifier is must, as the action event will receive this identifier as an argument

####Removing buttons
Buttons can be removed, so that new ones can be added
```swift
tabView.removeLeftButtons()
tabView.removeRightButtons()
```
####Modes of operation
KSTabview has 3 modes of operation viz None, One, Any
```swift
tabView.selectionType = .None       // Action event is triggered, no selection happens.
tabView.selectionType = .One        // Only the laest selection stays.
tabView.selectionType = .Any        // Every button acts as a switch.
```
####Chaining
Methods that are not intended to return anything return self, to facilitate method chaining
```swift
tabView.removeRightButtons()
    .pushButtonRight("Help", identifier: "help")
    .pushButtonRight("Modify", identifier: "modify")
    .pushButtonRight("Delete", identifier: "delete")
    .pushButtonRight("New", identifier: "new").selectedButtons = ["modify"]
```
