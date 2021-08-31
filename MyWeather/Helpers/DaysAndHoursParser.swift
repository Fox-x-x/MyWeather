//
//  DaysAndHoursParser.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 20.07.2021.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Извлекает часовую погоду из кэша
    func getHoursFromWeather(from weather: WeatherCached) -> [HourCached] {
        var hours = [HourCached]()
        
        let hoursCached = weather.hourly
        
        for hour in hoursCached {
            hours.append(hour)
        }
        
        // берем каждый третий элемент
        if hours.count > 27 {
            hours = hours.enumerated().filter { $0.offset < 27 && $0.offset % 3 == 0 }.map { $0.element }
        }
        
        return hours
    }
    
    /// Извлекает часовую погоду из данные, полученных из сети
    func getHoursFromWeather(from weather: Weather) -> [Hour] {
        var hours = [Hour]()
        
        let hoursFromNet = weather.hourly
        
        for hour in hoursFromNet {
            hours.append(hour)
        }
        
        // берем каждый третий элемент
        if hours.count > 27 {
            hours = hours.enumerated().filter { $0.offset < 27 && $0.offset % 3 == 0 }.map { $0.element }
        }
        
        return hours
    }
    
    /// Извлекает дневную погоду из кэша
    func getDaysFromWeather(from weather: WeatherCached) -> [DayCached] {
        var days = [DayCached]()
        
        let daysCached = weather.daily
        
        for day in daysCached {
            days.append(day)
        }
        
        return days
        
    }
    
    /// Извлекает дневную погоду из данныех, полученных из сети
    func getDaysFromWeather(from weather: Weather) -> [Day] {
        var days = [Day]()
        
        let daysFromNet = weather.daily
        
        for day in daysFromNet {
            days.append(day)
        }
        
        return days
        
    }
    
}
