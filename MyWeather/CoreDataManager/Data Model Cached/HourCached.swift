//
//  HourCached.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 06.07.2021.
//

import Foundation

struct HourCached {
    
    let dt: Int
    let temp, feelsLike: Double
    let pressure, humidity: Int
    let dewPoint, uvi: Double
    let clouds, visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let pop: Double
    let weather: [WeatherElementCached]
    
}
