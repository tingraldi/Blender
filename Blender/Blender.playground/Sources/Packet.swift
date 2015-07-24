//
//  Packet.swift
//  Blender
//
//  Created by Tony Ingraldi on 7/20/15.
//  Copyright (c) 2015 Majesty Software. All rights reserved.
//

import Foundation

public struct Packet {
    public let command: UTF8Char
    public let values: [Int8]

    public init(command stringCommand: String, values someValues: [Int8]) {
        let char = UTF8Char((stringCommand as NSString).characterAtIndex(0))
        command = char
        values = someValues
    }

    public init(data: NSData) {
        var tmpCommand = UTF8Char(0)
        data.getBytes(&tmpCommand, length: 1)
        command = tmpCommand

        var tmpValues = [Int8](count: data.length - 1, repeatedValue: 0)
        data.getBytes(&tmpValues, range: NSMakeRange(1, tmpValues.count))
        values = tmpValues
    }

    public var size: Int {
        return sizeof(UTF8Char) + sizeof(Int8) * values.count
    }

    public var data: NSData {
        var data = NSMutableData(bytes: [command], length: sizeof(UTF8Char))
        data.appendBytes(values, length: values.count * sizeof(Int8))
        return data
    }
}
