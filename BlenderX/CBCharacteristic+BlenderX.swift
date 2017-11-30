//
//  CBCharacteristic+Blender.swift
//  Blender
//
//  Created by Tony Ingraldi on 8/13/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import CoreBluetooth

extension CBCharacteristic {
    var data: NSData {
        return self.value! as NSData
    }
}

