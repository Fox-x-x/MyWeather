//
//  WeatherCached.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 06.07.2021.
//

import Foundation

struct WeatherCached {
    
    var lat: Double
    var lon: Double
    let timezone: String
    let timezoneOffset: Double
    let current: CurrentDataCached
    let hourly: [HourCached]
    let daily: [DayCached]
    
}
