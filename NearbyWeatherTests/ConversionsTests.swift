//
//  ConversionsTests.swift
//  NearbyWeatherTests
//
//  Created by Lukas Prokein on 11/11/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import XCTest
@testable import NearbyWeather

class ConversionsTests: XCTestCase {

    func testUnitsAbbreviations() {
        let celsiusUnit = TemperatureUnit.init(value: .celsius)
        XCTAssert(celsiusUnit.abbreviation == "°C", "Celsius abbreviation should be °C")
        
        let fahrenheitUnit = TemperatureUnit.init(value: .fahrenheit)
        XCTAssert(fahrenheitUnit.abbreviation == "°F", "Fahrenheit abbreviation should be °F")
        
        let kelvinUnit = TemperatureUnit.init(value: .kelvin)
        XCTAssert(kelvinUnit.abbreviation == "K", "Kelvin abbreviation should be K")
    }
    
    
    func testIntegerTemperatureConversion() {
        let kelvinTemperature: Double = 275.7
        let celsiusUnit = TemperatureUnit.init(value: .celsius)
        let celsiusInt = ConversionService.temperatureIntValue(forTemperatureUnit: celsiusUnit, fromRawTemperature: kelvinTemperature)
        XCTAssertNotNil(celsiusInt, "Celsius int value should not be NIL")
        XCTAssert(celsiusInt == 3, "Celsius int value of 275.7K should be 3")
        
        let fahrenheitUnit = TemperatureUnit.init(value: .fahrenheit)
        let fahrenheitInt = ConversionService.temperatureIntValue(forTemperatureUnit: fahrenheitUnit, fromRawTemperature: kelvinTemperature)
        XCTAssertNotNil(fahrenheitInt, "Fahrenheit int value should not be NIL")
        XCTAssert(fahrenheitInt == 37, "Fahrenheit int value of 275.7K should be 37")
        
        let kelvinUnit = TemperatureUnit.init(value: .kelvin)
        let kelvinInt = ConversionService.temperatureIntValue(forTemperatureUnit: kelvinUnit, fromRawTemperature: kelvinTemperature)
        XCTAssertNotNil(kelvinInt, "Fahrenheit int value should not be NIL")
        XCTAssert(kelvinInt == 276, "Fahrenheit int value of 275.7K should be 276")
    }
}
