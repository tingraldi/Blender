//
//  ViewController.swift
//  Blender
//
//  Created by Tony Ingraldi on 7/18/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import UIKit

let PI: CGFloat = 4.0 * atan(1.0)

class ViewController: UIViewController, RemoteControllerDelegate {
    var remoteController: RemoteController!
    @IBOutlet weak var leftMotorSlider: UISlider!
    @IBOutlet weak var rightMotorSlider: UISlider!
    @IBOutlet weak var hornButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    var leftSliderValue: Float = 0
    var rightSliderValue: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeRemoteController()
        configureAppearance()
    }

    func initializeRemoteController() {
        remoteController = RemoteController()
        remoteController.delegate = self
        remoteController.initialize()
    }

    func configureAppearance() {
        leftMotorSlider.layer.setAffineTransform(CGAffineTransformMakeRotation(PI * -0.5))
        rightMotorSlider.layer.setAffineTransform(CGAffineTransformMakeRotation(PI * -0.5))
        for button in [hornButton, lightButton, resetButton] {
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 5.0
        }
    }

    func remoteControllerIsInitialized(remoteController: RemoteController) {
        println("Remote controller is initialized")
    }

    func remoteController(remoteController: RemoteController, didReceivePacket packet: Packet) {
        println("Received echo packet for command \(packet.command)")
    }

    @IBAction func emitTone(sender: AnyObject) {
        remoteController.write(packet: Packet(command: "T", values: [1]))
    }

    @IBAction func endTone(sender: AnyObject) {
        remoteController.write(packet: Packet(command: "T", values: [0]))
    }

    @IBAction func lightOn(sender: AnyObject) {
        remoteController.write(packet: Packet(command: "B", values: [1]))
    }

    @IBAction func lightOff(sender: AnyObject) {
        remoteController.write(packet: Packet(command: "B", values: [0]))
    }

    @IBAction func sendRightMotorCommand(sender: UISlider) {
        if sender.value != rightSliderValue {
            let direction: UInt8 = sender.value < 0 ? 0 : 1
            let speed = UInt8(abs(sender.value))
            remoteController.write(packet: Packet(command: "R", values: [direction, speed]))
            rightSliderValue = sender.value
        }
    }

    @IBAction func sendLeftMotorCommand(sender: UISlider) {
        if sender.value != leftSliderValue {
            let direction: UInt8 = sender.value < 0 ? 0 : 1
            let speed = UInt8(abs(sender.value))
            remoteController.write(packet: Packet(command: "L", values: [direction, speed]))
            leftSliderValue = sender.value
        }
    }

    @IBAction func stopLeftMotor(sender: AnyObject) {
        remoteController.write(packet: Packet(command: "L", values: [0, 0]))
        leftMotorSlider.value = 0
    }

    @IBAction func stopRightMotor(sender: AnyObject) {
        remoteController.write(packet: Packet(command: "R", values: [0, 0]))
        rightMotorSlider.value = 0
    }

    @IBAction func reset(sender: AnyObject) {
        initializeRemoteController()
    }
}

