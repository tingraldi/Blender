//
//  TemperatureSampleTests.swift
//  Temperature Recorder Tests
//
//  Created by Tony Ingraldi on 12/1/17.
//  Copyright © 2017 Majesty Software. All rights reserved.
//

import XCTest
@testable import Temperature_Recorder

class TemperatureSampleTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testZero() {
        let sample = TemperatureSample(counts: 0)
        XCTAssertEqual(sample.temperatureCelsius, -50, "Incorrect Celsius for 0 counts")
    }

    func testMax() {
        let sample = TemperatureSample(counts: 1024)
        XCTAssertEqual(sample.temperatureCelsius, 450, "Incorrect Celsius for 1023 counts")
    }

    func testConversionZero() {
        let tempF = toFahrenheit(celsius: 0)
        XCTAssertEqual(tempF, 32, "Incorrect conversion to Fahrenheit")
    }

    func testConversionBoiling() {
        let tempF = toFahrenheit(celsius: 100)
        XCTAssertEqual(tempF, 212, "Incorrect conversion to Fahrenheit")
    }

}
