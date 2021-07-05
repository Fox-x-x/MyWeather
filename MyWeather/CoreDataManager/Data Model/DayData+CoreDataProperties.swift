//
//  DayData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension DayData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayData> {
        return NSFetchRequest<DayData>(entityName: "DayData")
    }

    @NSManaged public var clouds: Int16
    @NSManaged public var dewPoint: Double
    @NSManaged public var dt: Double
    @NSManaged public var humidity: Int16
    @NSManaged public var moonPhase: Double
    @NSManaged public var moonrise: Double
    @NSManaged public var moonset: Double
    @NSManaged public var pop: Double
    @NSManaged public var pressure: Int16
    @NSManaged public var rain: Double
    @NSManaged public var snow: Double
    @NSManaged public var sunrise: Double
    @NSManaged public var sunset: Double
    @NSManaged public var uvi: Double
    @NSManaged public var windDeg: Int16
    @NSManaged public var windSpeed: Double
    @NSManaged public var weatherData: WeatherData
    @NSManaged public var temp: TempData
    @NSManaged public var feelsLike: FeelsLikeData
    @NSManaged public var weather: NSSet?

}

// MARK: Generated accessors for weather
extension DayData {

    @objc(addWeatherObject:)
    @NSManaged public func addToWeather(_ value: WeatherElementData)

    @objc(removeWeatherObject:)
    @NSManaged public func removeFromWeather(_ value: WeatherElementData)

    @objc(addWeather:)
    @NSManaged public func addToWeather(_ values: NSSet)

    @objc(removeWeather:)
    @NSManaged public func removeFromWeather(_ values: NSSet)

}

extension DayData : Identifiable {

}
