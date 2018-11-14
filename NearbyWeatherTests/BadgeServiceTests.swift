//
//  BadgeServiceTests.swift
//  NearbyWeatherTests
//
//  Created by Lukas Prokein on 11/11/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import XCTest
@testable import NearbyWeather

class BadgeServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        NetworkingService.instantiateSharedInstance()
        NetworkingService.shared.reachabilityStatus = .connected
        BadgeService.instantiateSharedInstance()
        WeatherDataManager.instantiateSharedInstance()
        PreferencesManager.instantiateSharedInstance()
        WeatherDataManager.shared.bookmarkedLocations = [WeatherStationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))]
        PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: WeatherDataManager.shared.bookmarkedLocations.first!.identifier)
    }

    override func tearDown() {
        super.tearDown()
        
        WeatherDataManager.shared.bookmarkedLocations = [WeatherStationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))]
        PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: WeatherDataManager.shared.bookmarkedLocations.first!.identifier)
        sleep(3)
    }

    func testDisablingBadgeService() {
        BadgeService.shared.setBadgeServiceEnabled(false)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: kIsTemperatureOnAppIconEnabledKey), "Value for key kIsTemperatureOnAppIconEnabledKey should be false after disabled")
        BadgeService.shared.isAppIconBadgeNotificationEnabled { isEnabled in
            XCTAssertFalse(isEnabled, "isAppIconBadgeNotificationEnabled should be false after disabled")
        }
        XCTAssert(UIApplication.shared.applicationIconBadgeNumber == 0, "applicationIconBadgeNumber should be 0 after disabled")
    }
    
    func testEnablingBadgeService() {
        BadgeService.shared.setBadgeServiceEnabled(true)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: kIsTemperatureOnAppIconEnabledKey), "Value for key kIsTemperatureOnAppIconEnabledKey should be true after enabled")
        let expectation = XCTestExpectation(description: "isAppIconBadgeNotificationEnabled should be true after enabled")
        BadgeService.shared.isAppIconBadgeNotificationEnabled { isEnabled in
            XCTAssertTrue(isEnabled, "isAppIconBadgeNotificationEnabled should be true after enabled")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: WeatherDataManager.shared.bookmarkedLocations.first!.identifier)
        XCTAssert(UIApplication.shared.applicationIconBadgeNumber != 0, "applicationIconBadgeNumber should not be 0 after enabled")
    }
    
    func testSelectingPreferredBookmark() {
        // Create new mocked bookmark
        let mockedBratislava = WeatherStationDTO(identifier: 3060972, name: "Bratislava", country: "Slovakia", coordinates: Coordinates(latitude: 48.15, longitude: 17.11))
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
        let enableExpectation = XCTestExpectation(description: "isAppIconBadgeNotificationEnabled should be true after enabled")
        BadgeService.shared.isAppIconBadgeNotificationEnabled { isEnabled in
            XCTAssertTrue(isEnabled, "isAppIconBadgeNotificationEnabled should be true after enabled")
            enableExpectation.fulfill()
        }
        wait(for: [enableExpectation], timeout: 10.0)

        // Check valid icon badge
        let kelvinTemperature = WeatherDataManager.shared.preferredBookmarkData?.atmosphericInformation.temperatureKelvin
        XCTAssertNotNil(kelvinTemperature, "Kelvin temperature should not be null")
        let selectedUnit = PreferencesManager.shared.temperatureUnit
        let expectedTemperature = ConversionService.temperatureIntValue(forTemperatureUnit: selectedUnit, fromRawTemperature: kelvinTemperature!)
        XCTAssert(UIApplication.shared.applicationIconBadgeNumber == expectedTemperature, "applicationIconBadgeNumber should not be set to right temeperature")
    }
}
