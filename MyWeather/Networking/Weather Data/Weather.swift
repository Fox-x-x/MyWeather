//
//  Weather.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.06.2021.
//

import Foundation

struct Weather: Codable {
    
    let lat, lon: Double
    let timezone: String
    let timezoneOffset: Double
    let current: Current
    let hourly: [Hour]
    let daily: [Day]
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current, hourly, daily
    }
}
