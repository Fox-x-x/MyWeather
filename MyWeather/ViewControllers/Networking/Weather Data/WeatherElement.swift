//
//  WeatherElement.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.06.2021.
//

import Foundation

struct WeatherElement: Codable {
    let id: Int
    let weatherDescription: String

    enum CodingKeys: String, CodingKey {
        case id
        case weatherDescription = "description"
    }
}
