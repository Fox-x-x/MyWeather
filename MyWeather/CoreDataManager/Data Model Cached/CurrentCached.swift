//
//  CurrentCached.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 06.07.2021.
//

import Foundation

struct CurrentDataCached {
    
    var dt: Double?
    let sunrise, sunset: Double?
    let temp, feelsLike: Double?
    let pressure, humidity: Int?
    let dewPoint, uvi: Double?
    let clouds, visibility: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let weather: [WeatherElementCached]?
    
}
