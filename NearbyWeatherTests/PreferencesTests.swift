//
//  PreferencesTests.swift
//  NearbyWeatherTests
//
//  Created by Lukas Prokein on 12/11/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import XCTest
@testable import NearbyWeather
import Hippolyte

class PreferencesTests: XCTestCase {

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
        
        NetworkingService.instantiateSharedInstance()
        NetworkingService.shared.reachabilityStatus = .connected
        BadgeService.instantiateSharedInstance()
        WeatherDataManager.instantiateSharedInstance()
        PreferencesManager.instantiateSharedInstance()
        WeatherDataManager.shared.bookmarkedLocations = [WeatherStationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))]
        PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: WeatherDataManager.shared.bookmarkedLocations.first!.identifier)
        PreferencesManager.shared.distanceSpeedUnit = DistanceSpeedUnit(value: .kilometres)
        PreferencesManager.shared.temperatureUnit = TemperatureUnit(value: .celsius)
        sleep(3)
    }
    
    override func tearDown() {
        super.tearDown()
        
        Hippolyte.shared.stop()
        Hippolyte.shared.clearStubs()
        sleep(2)
        
        WeatherDataManager.shared.bookmarkedLocations = [WeatherStationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))]
        PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: WeatherDataManager.shared.bookmarkedLocations.first!.identifier)
        PreferencesManager.shared.distanceSpeedUnit = DistanceSpeedUnit(value: .kilometres)
        PreferencesManager.shared.temperatureUnit = TemperatureUnit(value: .celsius)
        sleep(2)
    }
    
    func testDistanceSettings() {
        let newSpeedUnit = DistanceSpeedUnit(value: .miles)
        PreferencesManager.shared.distanceSpeedUnit = newSpeedUnit
        sleep(3)
        
        let retrievedPreferences = DataStorageService.retrieveJsonFromFile(with: "PreferencesManagerStoredContents", andDecodeAsType: PreferencesManagerStoredContentsWrapper.self, fromStorageLocation: .applicationSupport)
        XCTAssertNotNil(retrievedPreferences, "Retrieved preferences should not be nil")
        XCTAssert(retrievedPreferences!.windspeedUnit.value == newSpeedUnit.value, "Retrieved speed unit should be \(newSpeedUnit.stringValue)")
    }
    
    func testTemperatureSettings() {
        let newTemperatureUnit = TemperatureUnit(value: .fahrenheit)
        PreferencesManager.shared.temperatureUnit = newTemperatureUnit
        sleep(3)
        
        let retrievedPreferences = DataStorageService.retrieveJsonFromFile(with: "PreferencesManagerStoredContents", andDecodeAsType: PreferencesManagerStoredContentsWrapper.self, fromStorageLocation: .applicationSupport)
        XCTAssertNotNil(retrievedPreferences, "Retrieved preferences should not be nil")
        XCTAssert(retrievedPreferences!.temperatureUnit.value == newTemperatureUnit.value, "Retrieved temperature unit should be \(newTemperatureUnit.stringValue)")
    }
    
    func testTemperatureSettingsBadgeUpdate() {
        // Create new mocked bookmark
        let mockedBratislava = WeatherStationDTO(identifier: 865084, name: "Kosice", country: "Slovakia", coordinates: Coordinates(latitude: 48.67, longitude: 21.33))
        var bookmarks = WeatherDataManager.shared.bookmarkedLocations
        bookmarks.append(mockedBratislava)
        WeatherDataManager.shared.bookmarkedLocations = bookmarks
        sleep(2)
        
        // Update data
        let expectation = XCTestExpectation(description: "Weather data should update")
        WeatherDataManager.shared.update { status in
            XCTAssert(status == .success, "Weather data update status should be success")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        // Enable and select preferred bookmark
        PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: mockedBratislava.identifier)
        BadgeService.shared.setBadgeServiceEnabled(true)
        
        let rawTemperature = WeatherDataManager.shared.preferredBookmarkData?.atmosphericInformation.temperatureKelvin
        XCTAssertNotNil(rawTemperature, "Preferred bookmark temeperature should not be nil")
        let celsiusUnit = TemperatureUnit(value: .celsius)
        DispatchQueue.main.async {
            PreferencesManager.shared.temperatureUnit = celsiusUnit
        }
        let celiusExpectation = XCTestExpectation(description: "Celsius should trigger update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            celiusExpectation.fulfill()
        }
        wait(for: [celiusExpectation], timeout: 10.0)
        let celsiusTemperature = ConversionService.temperatureIntValue(forTemperatureUnit: celsiusUnit, fromRawTemperature: rawTemperature!)
        XCTAssertNotNil(celsiusTemperature, "Celius temeperature should not be nil")
        XCTAssert(UIApplication.shared.applicationIconBadgeNumber == celsiusTemperature!, "Badge number should be equal \(celsiusTemperature!) but is \(UIApplication.shared.applicationIconBadgeNumber)")
        
        let fahrenheitUnit = TemperatureUnit(value: .fahrenheit)
        DispatchQueue.main.async {
            PreferencesManager.shared.temperatureUnit = fahrenheitUnit
        }
        let fahrenheitExpectation = XCTestExpectation(description: "Fahrenheit should trigger update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fahrenheitExpectation.fulfill()
        }
        wait(for: [fahrenheitExpectation], timeout: 10.0)
        let fahrenheitTemperature = ConversionService.temperatureIntValue(forTemperatureUnit: fahrenheitUnit, fromRawTemperature: rawTemperature!)
        XCTAssertNotNil(fahrenheitTemperature, "Fahrenheit temeperature should not be nil")
        XCTAssert(UIApplication.shared.applicationIconBadgeNumber == fahrenheitTemperature!, "Badge number should be equal \(fahrenheitTemperature!) but is \(UIApplication.shared.applicationIconBadgeNumber)")
        
        let kelvinUnit = TemperatureUnit(value: .kelvin)
        DispatchQueue.main.async {
            PreferencesManager.shared.temperatureUnit = kelvinUnit
        }
        let kelvinExpectation = XCTestExpectation(description: "Kelvin should trigger update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            kelvinExpectation.fulfill()
        }
        wait(for: [kelvinExpectation], timeout: 10.0)
        let kelvinTemperature = ConversionService.temperatureIntValue(forTemperatureUnit: kelvinUnit, fromRawTemperature: rawTemperature!)
        XCTAssertNotNil(kelvinTemperature, "Kelvin temeperature should not be nil")
        XCTAssert(UIApplication.shared.applicationIconBadgeNumber == kelvinTemperature!, "Badge number should be equal \(kelvinTemperature!) but is \(UIApplication.shared.applicationIconBadgeNumber)")
    }
}
