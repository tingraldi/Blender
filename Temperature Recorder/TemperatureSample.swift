//
//  TemperatureSample.swift
//  Temperature Recorder
//
//  Created by Tony Ingraldi on 12/1/17.
//  Copyright © 2017 Majesty Software. All rights reserved.
//

import Foundation

func celsiusFromCounts(counts: UInt16) -> Double {
    let voltage = (Double(counts) / 1024.0) * 5.0
    return (voltage - 0.5) * 100.0
}

func toFahrenheit(celsius: Double) -> Double {
    return (9.0 / 5.0) * celsius + 32.0
}

class TemperatureSample: NSObject {
    let counts: UInt16
    let temperatureCelsius: Double
    let temperatureFahrenheit: Double
    let date: Date

    init(counts: UInt16) {
        self.counts = counts
        temperatureCelsius = celsiusFromCounts(counts: counts)
        temperatureFahrenheit = toFahrenheit(celsius: temperatureCelsius)
        date = Date()
    }

    override var description: String {
        return "\(temperatureCelsius)°C, \(temperatureFahrenheit)°F @ \(date)"
    }

    override func value(forKey key: String) -> Any? {
        print(key)
        return super.value(forKey: key)
    }
}
