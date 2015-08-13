//
//  ViewController+Blender.swift
//  Blender
//
//  Created by Tony Ingraldi on 8/13/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import Foundation

extension ViewController: RemoteControllerDelegate {

    func initializeRemoteController() {
        remoteController = RedBearRemoteController()
        remoteController.delegate = self
        setButtonState(false)
        remoteController.initialize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeRemoteController()
        prepareForUse()
    }
    
    func setButtonState(state: Bool) {
        hornButton.enabled = state
        lightButton.enabled = state
    }

    func remoteController(remoteController: RemoteController, didReceivePacket packet: Packet) {
        println("Received echo packet for command \(packet.commandString)")
    }

    func remoteControllerIsInitialized(remoteController: RemoteController) {
        println("Remote controller is initialized")
        self.remoteController.write(packet: Packet(command: "S", values: nil))
        setButtonState(true)
    }

    @IBAction func reset(sender: AnyObject) {
        setButtonState(false)
        initializeRemoteController()
    }
}