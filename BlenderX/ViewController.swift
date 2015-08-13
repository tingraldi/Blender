//
//  ViewController.swift
//  BlenderX
//
//  Created by Tony Ingraldi on 8/12/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var remoteController: RemoteController!
    var lightState: UInt8 = 0
    var hornState: UInt8 = 0
    @IBOutlet weak var hornButton: NSButton!
    @IBOutlet weak var lightButton: NSButton!

    func prepareForUse() {
        remoteController.usesExplicitServiceUUIDs = false // on OS X, explicit scan for services seems to be unreliable
    }
    
    @IBAction func toggleTone(sender: AnyObject) {
        hornState = 1 - hornState
        remoteController.write(packet: Packet(command: "T", values: [hornState]))
    }

    @IBAction func toggleLight(sender: AnyObject) {
        lightState = 1 - lightState
        remoteController.write(packet: Packet(command: "B", values: [lightState]))
    }
}

