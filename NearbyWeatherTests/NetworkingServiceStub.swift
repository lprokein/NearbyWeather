//
//  NetworkingServiceStub.swift
//  NearbyWeatherTests
//
//  Created by Lukas Prokein on 11/11/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class NetworkingServiceStub {
    static let cityId = 865084
    static let expectedTemperature = 278.15
    static let expectedPressure: Double = 1023
    static let expectedWindSpeed = 0.5
    static let expectedWeatherConditionName = "Clouds"
    static let response: String =
    """
    {"coord":{"lon":21.33,"lat":48.67},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"base":"stations","main":{"temp":278.15,"pressure":1023,"humidity":93,"temp_min":278.15,"temp_max":278.15},"visibility":7000,"wind":{"speed":0.5},"clouds":{"all":48},"dt":1541971800,"sys":{"type":1,"id":5907,"message":0.0129,"country":"SK","sunrise":1541914677,"sunset":1541948340},"id":865084,"name":"Košický Kraj","cod":200}
    """
}
