//
//  Daily.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.06.2021.
//

import Foundation

struct Day: Codable {
    let dt, sunrise, sunset, moonrise: Double
    let moonset: Double
    let moonPhase: Double
    let temp: Temp
    let feelsLike: FeelsLike
    let pressure, humidity: Int
    let dewPoint, windSpeed: Double
    let windDeg: Int
    let weather: [WeatherElement]
    let clouds: Int
    let pop, uvi: Double
    let rain: Double?
    let snow: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather, clouds, pop, uvi, rain, snow
    }
}
