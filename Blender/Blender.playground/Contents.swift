//: Playground - noun: a place where people can play

import UIKit

let values: [Int8] = [1, 2, 3, 4]

let packet = Packet(command: "B", values: values)

packet.command
packet.values

packet.size

packet.data

let newPacket = Packet(data: packet.data)

newPacket.command
newPacket.values
newPacket.data

let a = "ABC"

let v = UIView()
Character(UnicodeScalar(packet.command))

Int8.max
Int8.min



