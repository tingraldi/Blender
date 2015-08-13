//
//  RemoteController.swift
//  Blender
//
//  Created by Tony Ingraldi on 7/18/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import CoreBluetooth


let DummyUUID = CBUUID(string: "00000000-0000-0000-0000-000000000000")


protocol RemoteControllerDelegate : NSObjectProtocol {
    func remoteController(remoteController: RemoteController, didReceivePacket packet: Packet)
    func remoteControllerIsInitialized(remoteController: RemoteController)
}


class RemoteController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var peripheral: CBPeripheral?
    private var centralManager: CBCentralManager!
    private var characteristics = [CBUUID:CBCharacteristic]()
    var usesExplicitServiceUUIDs = true

    var deviceServiceUUID: CBUUID {
        return DummyUUID
    }
    var deviceServiceUUIDs: [CBUUID]? {
        var UUIDs: [CBUUID]? = usesExplicitServiceUUIDs ? [deviceServiceUUID] : nil
        return UUIDs
    }
    var receiveCharacteristicUUID: CBUUID { // receive from perspective of peripheral
        return DummyUUID
    }
    var transmitCharacteristicUUID: CBUUID { // transmit from perspective of peripheral
        return DummyUUID
    }

    var delegate: RemoteControllerDelegate?

    func initialize() {
        println("Initializing")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if (central.state == .PoweredOn && peripheral == nil) {
            println("Starting scan for peripherals")
            centralManager.scanForPeripheralsWithServices(self.deviceServiceUUIDs, options: nil)
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
        peripheral.discoverServices(self.deviceServiceUUIDs);
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
            peripheral.discoverCharacteristics([self.transmitCharacteristicUUID, self.receiveCharacteristicUUID], forService: service)
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

        if let transmitCharacteristic = characteristics[self.transmitCharacteristicUUID] {
            self.peripheral?.setNotifyValue(true, forCharacteristic: transmitCharacteristic)
            self.delegate?.remoteControllerIsInitialized(self)
        }

        if let actualError = error {
            println(actualError.localizedDescription)
        }
    }

    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if error == nil {
            let packet = Packet(data: characteristic.data)
            self.delegate?.remoteController(self, didReceivePacket: packet)
        } else {
            println(error)
        }
    }

    func read() {
        self.peripheral?.readValueForCharacteristic(self.characteristics[self.transmitCharacteristicUUID])
    }

    func write(#data: NSData) {
        if (peripheral?.state == .Connected) {
            self.peripheral?.writeValue(data, forCharacteristic: self.characteristics[self.receiveCharacteristicUUID], type: .WithoutResponse)
        } else {
            println("Refusing to write to a disconnected peripheral")
        }
    }

    func write(#packet: Packet) {
        println("Writing packet \(packet)")
        self.write(data: packet.data)
    }
}
