//
//  NetworkServiceTests.swift
//  NearbyWeatherTests
//
//  Created by Lukas Prokein on 11/11/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import XCTest
@testable import NearbyWeather
import Hippolyte

class NetworkServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?APPID=39170eb470cc5fd83202df3a7c6e1cac&id=865084")!
        var stub = StubRequest(method: .GET, url: url)
        var response = StubResponse()
        let body = NetworkingServiceStub.response.data(using: .utf8)!
        response.body = body
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()
        
        WeatherDataManager.instantiateSharedInstance()
        NetworkingService.instantiateSharedInstance()
        BadgeService.instantiateSharedInstance()
        PreferencesManager.instantiateSharedInstance()
    }

    override func tearDown() {
        Hippolyte.shared.stop()
        Hippolyte.shared.clearStubs()
        
        sleep(2)
        NetworkingService.shared = nil
        WeatherDataManager.shared = nil
        BadgeService.shared = nil
        PreferencesManager.shared = nil
        
        super.tearDown()
    }
    
    func testSingleCityWeatherFetch() {
        let expectation = XCTestExpectation(description: "Weather data should fetch")
        NetworkingService.shared.fetchWeatherInformationForStation(withIdentifier: NetworkingServiceStub.cityId) { weatherData in
            XCTAssertNotNil(weatherData.weatherInformationDTO, "Weather info should not be nil")
            XCTAssertNil(weatherData.errorDataDTO, "Error info should be nil")
            let weatherInfo = weatherData.weatherInformationDTO!
            XCTAssert(weatherInfo.atmosphericInformation.temperatureKelvin == NetworkingServiceStub.expectedTemperature, "Expected temperature should be \(NetworkingServiceStub.expectedTemperature)")
            XCTAssert(weatherInfo.atmosphericInformation.pressurePsi == NetworkingServiceStub.expectedPressure, "Expected pressure should be \(NetworkingServiceStub.expectedPressure)")
            XCTAssert(weatherInfo.windInformation.windspeed == NetworkingServiceStub.expectedWindSpeed, "Expected windspeed should be \(NetworkingServiceStub.expectedWindSpeed)")
            XCTAssertNotNil(weatherInfo.weatherCondition.first, "There should be 1 weather condition")
            XCTAssert(weatherInfo.weatherCondition.first!.conditionName == NetworkingServiceStub.expectedWeatherConditionName, "Expected weather condition should be \(NetworkingServiceStub.expectedWeatherConditionName)")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
