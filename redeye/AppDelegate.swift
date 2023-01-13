//  AppDelegate.swift
//  redeye
//
//  Created by Walker Cole Sutton on 11/4/20.
//

import Cocoa
import SwiftUI

import IOKit.ps

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//  var popover: NSPopover!
  var statusBarItem: NSStatusItem!

  func applicationDidFinishLaunching(_ aNotification: Notification) {

      let statusBar = NSStatusBar.system
      statusBarItem = statusBar.statusItem(
          withLength: NSStatusItem.squareLength)
      statusBarItem.button?.image = NSImage(named: "Icon")

//      let statusBarMenu = NSMenu(title: "RedEye Bar Menu")
      let statusBarMenu = NSMenu()
      statusBarItem.menu = statusBarMenu

    statusBarMenu.addItem(
        withTitle: "Battery Info",
        action: #selector(AppDelegate.batteryInfo),
        keyEquivalent: "")

    statusBarMenu.addItem(
        withTitle: "Preferences",
        action: #selector(AppDelegate.preferences),
        keyEquivalent: "")

    statusBarMenu.addItem(
        withTitle: "Help",
        action: #selector(AppDelegate.help),
        keyEquivalent: "")

    statusBarMenu.addItem(
        withTitle: "About",
        action: #selector(AppDelegate.about),
        keyEquivalent: "")

    statusBarMenu.addItem(
        withTitle: "Quit",
        action: #selector(AppDelegate.quit),
        keyEquivalent: "")
    
    while (true) {
      if (getBatteryInfo() < 95) {
        print("LOW BATTERY")
      }
      do {
        sleep(4)
      }
    }
  }
  
  @objc func batteryInfo() {
      print("batteryInfo")
  }

  @objc func preferences() {
      print("preferences")
  }

  @objc func help() {
      print("help")
  }

  @objc func about() {
      print("about")
  }

  @objc func quit() {
      print("quit")
  }
  
  func getBatteryInfo() -> Int {
    guard let dict = (IOPSCopyPowerSourcesInfo().takeRetainedValue() as? NSArray)?.firstObject as? NSDictionary else { return -1 }
    return dict[kIOPSCurrentCapacityKey] as? Int ?? -1
  //    let isCharging = dict[kIOPSIsChargingKey] as? Bool ?? false
  //    let currentCapacity = dict[kIOPSCurrentCapacityKey] as? Int
  //    let delegate?.batteryAlertProtocolUpdated()


  //    let snapshot = IOKit.power
  //    print(snapshot)

  }

}
