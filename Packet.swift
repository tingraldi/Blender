//
//  Packet.swift
//  Blender
//
//  Created by Tony Ingraldi on 7/20/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import Foundation

struct Packet {
    let command: UTF8Char
    let values: [UInt8]?

    init(command: UTF8Char, values: [UInt8]? = nil) {
        self.command = command
        self.values = values
    }

    init(command stringCommand: String, values: [UInt8]? = nil) {
        let command = UTF8Char((stringCommand as NSString).character(at: 0))
        self.init(command: command, values: values)
    }

    init(data: NSData) {
        var command = UTF8Char(0)
        data.getBytes(&command, length: 1)

        var values = [UInt8](repeating: 0, count: data.length - 1)
        data.getBytes(&values, range: NSMakeRange(1, values.count))

        self.init(command: command, values: values)
    }

    var commandString: Character {
        return Character(UnicodeScalar(command))
    }

    var size: Int {
        var size = MemoryLayout<UTF8Char>.size
        if values != nil {
            size += MemoryLayout.size(ofValue: UInt8()) * values!.count
        }
        return size
    }

    var data: NSData {
        let data = NSMutableData(bytes: [command], length: MemoryLayout.size(ofValue: UTF8Char()))
        if (values != nil) {
            data.append(values!, length: values!.count * MemoryLayout.size(ofValue: UInt8()))
        }
        return data
    }

    var description: String {
        return "\(String(commandString)): \(String(describing: values))"
    }
}
