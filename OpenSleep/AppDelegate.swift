//
//  AppDelegate.swift
//  OpenSleep
//
//  Created by Jason Lam on 23/11/2018.
//  Copyright © 2018 Jason Lam. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var isSleepable = true
    
    var caffTask : Process?
    
    func _cleanUp(){
        
        if let p = caffTask {
            p.interrupt()
            caffTask = nil
        }
        
        let fin = Process()
        fin.launchPath = "/usr/bin/killall"
        fin.arguments = ["-9", "caffeinate"]
        fin.launch()
    }

    func executeCaffeinate(){
        
        if !self.isSleepable {
            let p = Process()
            p.launchPath = "/usr/bin/caffeinate"
            p.arguments = ["-d"]
            p.launch()
            self.caffTask = p
        }
        
        self.syncMenu()
    }
    
    @objc func toggleNoSleep(_ sender: Any?){
        
        _cleanUp()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            
            self.isSleepable = !self.isSleepable
            
            self.executeCaffeinate()
        }
        
    }
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    let icoOnSun = "No Sleep ☀ => ☾"
    let icoOffMoon = "May Sleep ☾ => ☀"
    
    let iconMoon = NSImage(named: NSImage.Name("IconMoon"))
    let iconSun = NSImage(named: NSImage.Name("IconSun"))
    
    func nowIsSleepableText() -> String{
        return isSleepable ? icoOffMoon : icoOnSun
    }
    
    func nowIsSleepableImage() -> NSImage{
        return isSleepable ? iconMoon! : iconSun!
    }
    
    func syncMenu(){
        
        if let btn = statusItem.button {
            btn.title = ""
            btn.image = nowIsSleepableImage()
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "" + nowIsSleepableText(), action: #selector(AppDelegate.toggleNoSleep(_:)), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
    
    @objc func onDisplayConnect(){
        if NSScreen.screens.count > 1 && isSleepable {
            isSleepable = false
            executeCaffeinate()
        } else if !isSleepable && NSScreen.screens.count == 1 {
            isSleepable = true
            executeCaffeinate()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        syncMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDisplayConnect), name: NSApplication.didChangeScreenParametersNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onDisplayConnect), name: UIScreenDidDisconnectNotification, object: nil)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        _cleanUp()
    }


}

