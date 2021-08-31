//
//  Options.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.07.2021.
//

import Foundation

enum Options: String {
    case temperature = "temperature"
    case windSpeed = "windSpeed"
    case timeFormat = "timeFormat"
}

struct OptionsStack {
    var temperature: TemperatureFormat
    var winSpeed: WindSpeed
    var timeFormat: TimeFormat
}

enum TemperatureFormat {
    case celsius
    case fahrenheit
}

enum WindSpeed {
    case miles
    case kilometers
}

enum TimeFormat {
    case hours24
    case hours12
}

func convertTemperature(_ temperature: Double, to format: TemperatureFormat) -> Double {
    
    var temp = temperature
    
    if format == .fahrenheit {
        temp = temp * 9/5 + 32
    }
    
    return temp
}

func convertWindSpeed(_ speed: Double, to format: WindSpeed) -> Double {
    
    var windSpeed = speed
    
    if format == .miles {
        windSpeed = windSpeed / 3.6
    }
    
    return windSpeed
}

func loadSettings() -> OptionsStack {
    
    let defaults = UserDefaults.standard
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    // загружаем настройки
    let temperature = defaults.object(forKey: Options.temperature.rawValue) as? String ?? "C"
    if temperature == "C" {
        options.temperature = .celsius
    } else {
        options.temperature = .fahrenheit
    }
    
    let windSpeed = defaults.object(forKey: Options.windSpeed.rawValue) as? String ?? "Km"
    if windSpeed == "Km" {
        options.winSpeed = .kilometers
    } else {
        options.winSpeed = .miles
    }
    
    let time = defaults.object(forKey: Options.timeFormat.rawValue) as? String ?? "24"
    if time == "24" {
        options.timeFormat = .hours24
    } else {
        options.timeFormat = .hours12
    }
    
    return options
    
}
