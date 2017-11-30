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
        let UUIDs: [CBUUID]? = usesExplicitServiceUUIDs ? [deviceServiceUUID] : nil
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
        print("Initializing")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn && peripheral == nil) {
            print("Starting scan for peripherals")
            centralManager.scanForPeripherals(withServices: self.deviceServiceUUIDs, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral \(peripheral)")
        central.stopScan()
        self.peripheral = peripheral;
        peripheral.delegate = self;
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(String(describing: error))")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral)")
        peripheral.discoverServices(self.deviceServiceUUIDs);
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral)")
        if let actualError = error {
            print(actualError.localizedDescription)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        for service: CBService in services {
            print("Discovered service \(service)")
            peripheral.discoverCharacteristics([self.transmitCharacteristicUUID, self.receiveCharacteristicUUID], for: service)
        }
        if let actualError = error {
            print(actualError.localizedDescription)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let localCharacteristics = service.characteristics else {
            return
        }

        for characteristic in localCharacteristics {
            print("Discovered characteristic \(characteristic) for service \(service)")
            characteristics[characteristic.uuid] = characteristic
        }

        if let transmitCharacteristic = characteristics[self.transmitCharacteristicUUID] {
            self.peripheral?.setNotifyValue(true, for: transmitCharacteristic)
            self.delegate?.remoteControllerIsInitialized(remoteController: self)
        }

        if let actualError = error {
            print(actualError.localizedDescription)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            let packet = Packet(data: characteristic.data)
            self.delegate?.remoteController(remoteController: self, didReceivePacket: packet)
        } else {
            print(error!)
        }
    }

    func read() {
        self.peripheral?.readValue(for: self.characteristics[self.transmitCharacteristicUUID]!)
    }

    func write(data: NSData) {
        if (peripheral?.state == .connected) {
            self.peripheral?.writeValue(data as Data, for: self.characteristics[self.receiveCharacteristicUUID]!, type: .withoutResponse)
        } else {
            print("Refusing to write to a disconnected peripheral")
        }
    }

    func write(packet: Packet) {
        print("Writing packet \(packet)")
        self.write(data: packet.data)
    }
}
