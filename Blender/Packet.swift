//
//  Packet.swift
//  Blender
//
//  Created by Tony Ingraldi on 7/20/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import Foundation

struct Packet : Printable {
    let command: UTF8Char
    let values: [UInt8]?

    init(command stringCommand: String, values someValues: [UInt8]? = nil) {
        let char = UTF8Char((stringCommand as NSString).characterAtIndex(0))
        command = char
        values = someValues
    }

    init(data: NSData) {
        var tmpCommand = UTF8Char(0)
        data.getBytes(&tmpCommand, length: 1)
        command = tmpCommand

        var tmpValues = [UInt8](count: data.length - 1, repeatedValue: 0)
        data.getBytes(&tmpValues, range: NSMakeRange(1, tmpValues.count))
        values = tmpValues
    }

    var size: Int {
        var size = sizeof(UTF8Char)
        if values != nil {
            size += sizeof(UInt8) * values!.count
        }
        return size
    }

    var data: NSData {
        var data = NSMutableData(bytes: [command], length: sizeof(UTF8Char))
        if (values != nil) {
            data.appendBytes(values!, length: values!.count * sizeof(UInt8))
        }
        return data
    }

    var description: String {
        return "\(Character(UnicodeScalar(command))): \(values)"
    }
}
