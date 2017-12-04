//
//  ViewController.swift
//  Temperature Recorder
//
//  Created by Tony Ingraldi on 11/30/17.
//  Copyright © 2017 Majesty Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, RemoteControllerDelegate {
    var remoteController: RemoteController!
    var timer: Timer?

    @IBOutlet weak var celsiusField: NSTextField?
    @IBOutlet weak var fahrenheitField: NSTextField?
    @IBOutlet weak var dateLabel: NSTextField?

    var sample: TemperatureSample? {
        didSet {
            update()
        }
    }

    func update() {
        celsiusField?.doubleValue = sample!.temperatureCelsius
        fahrenheitField?.doubleValue = sample!.temperatureFahrenheit
        dateLabel?.objectValue = sample!.date
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeRemoteController()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        view.window?.title = "Temperature"
        view.window?.styleMask.remove(.resizable)
    }

    func initializeRemoteController() {
        remoteController = RedBearRemoteController()
        remoteController.delegate = self
        remoteController.initialize()
    }

    func remoteController(remoteController: RemoteController, didReceivePacket packet: Packet) {
        var counts: UInt16 = 0
        packet.data.getBytes(&counts, range: NSRange(location: 1, length: 2))
        counts = CFSwapInt16BigToHost(counts) // data is transmitted in network byte order (big-endian)
        sample = TemperatureSample(counts: counts)
        NSLog("\(sample!)")
    }

    @objc func pollForTemperature() {
        self.remoteController.write(packet: Packet(command: "T", values: nil))
    }

    func remoteControllerIsInitialized(remoteController: RemoteController) {
        NSLog("Remote controller is initialized")
        timer = Timer.init(timeInterval: 600, repeats: true, block: {timer in self.pollForTemperature()})
        timer!.fire()
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
}

