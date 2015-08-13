//
//  RedBearRemoteController.swift
//  Blender
//
//  Created by Tony Ingraldi on 8/13/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import CoreBluetooth

let RedBearDeviceServiceUUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
let RedBearTransmitCharacteristicUUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")
let RedBearReceiveCharacteristicUUID = CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")

class RedBearRemoteController: RemoteController {
    override var deviceServiceUUID: CBUUID {
        return RedBearDeviceServiceUUID
    }
    override var receiveCharacteristicUUID: CBUUID {
        return RedBearReceiveCharacteristicUUID
    }
    override var transmitCharacteristicUUID: CBUUID {
        return RedBearTransmitCharacteristicUUID
    }
}