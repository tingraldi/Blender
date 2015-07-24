//
//  RemoteController.swift
//  Blender
//
//  Created by Tony Ingraldi on 7/18/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import UIKit
import CoreBluetooth


let RedBearDeviceServiceUUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
let RedBearTransmitCharacteristicUUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")
let RedBearReceiveCharacteristicUUID = CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")

protocol RemoteControllerDelegate : NSObjectProtocol {
    func remoteController(remoteController: RemoteController, didReceivePacket packet: Packet)
    func remoteControllerIsInitialized(remoteController: RemoteController)
}

class RemoteController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var peripheral: CBPeripheral?
    private var centralManager: CBCentralManager!
    private var characteristics = [CBUUID:CBCharacteristic]()
    var delegate: RemoteControllerDelegate?

    func initialize() {
        println("Initializing")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if (central.state == .PoweredOn && peripheral == nil) {
            println("Starting scan for peripherals")
            centralManager.scanForPeripheralsWithServices([RedBearDeviceServiceUUID], options: nil)
        }
    }

    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!,
        advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
            central.stopScan()
            self.peripheral = peripheral;
            peripheral?.delegate = self;
            central.connectPeripheral(peripheral, options: nil)
    }

    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected to \(peripheral)")
        peripheral.discoverServices([RedBearDeviceServiceUUID]);
    }

    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Disconnected from \(peripheral)")
        if let actualError = error {
            println(actualError.localizedDescription)
        }
    }

    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service: CBService in peripheral.services as! [CBService] {
            println("Discovered service \(service)")
            peripheral.discoverCharacteristics([RedBearTransmitCharacteristicUUID, RedBearReceiveCharacteristicUUID], forService: service)
        }
        if let actualError = error {
            println(actualError.localizedDescription)
        }
    }

    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for characteristic in service.characteristics as! [CBCharacteristic] {
            println("Discovered characteristic \(characteristic) for service \(service)")
            characteristics[characteristic.UUID] = characteristic
        }

        if let transmitCharacteristic = characteristics[RedBearTransmitCharacteristicUUID] {
            self.peripheral?.setNotifyValue(true, forCharacteristic: transmitCharacteristic)
            self.delegate?.remoteControllerIsInitialized(self)
        }

        if let actualError = error {
            println(actualError.localizedDescription)
        }
    }

    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if error == nil {
            let packet = Packet(data: characteristic.value)
            self.delegate?.remoteController(self, didReceivePacket: packet)
        } else {
            println(error)
        }
    }

    func read() {
        self.peripheral?.readValueForCharacteristic(self.characteristics[RedBearTransmitCharacteristicUUID])
    }

    func write(#data: NSData) {
        if (peripheral?.state == .Connected) {
            self.peripheral?.writeValue(data, forCharacteristic: self.characteristics[RedBearReceiveCharacteristicUUID], type: .WithoutResponse)
        } else {
            println("Refusing to write to a disconnected peripheral")
        }
    }

    func write(#packet: Packet) {
        println("Writing packet \(packet)")
        self.write(data: packet.data)
    }
}
