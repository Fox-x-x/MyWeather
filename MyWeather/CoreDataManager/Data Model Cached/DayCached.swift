//
//  DayCached.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 06.07.2021.
//

import Foundation

struct DayCached {
    
    let dt, sunrise, sunset, moonrise: Double
    let moonset: Double
    let moonPhase: Double
    let temp: TempCached
    let feelsLike: FeelsLikeCached
    let pressure, humidity: Int
    let dewPoint, windSpeed: Double
    let windDeg: Int
    let weather: [WeatherElementCached]
    let clouds: Int
    let pop, uvi: Double
    let rain: Double?
    let snow: Double?
    
}
