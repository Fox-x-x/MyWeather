//
//  HourData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension HourData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HourData> {
        return NSFetchRequest<HourData>(entityName: "HourData")
    }

    @NSManaged public var clouds: Int16
    @NSManaged public var dewPoint: Double
    @NSManaged public var dt: Int32
    @NSManaged public var feelsLike: Double
    @NSManaged public var humidity: Int16
    @NSManaged public var pop: Double
    @NSManaged public var pressure: Int16
    @NSManaged public var temp: Double
    @NSManaged public var uvi: Double
    @NSManaged public var visibility: Int16
    @NSManaged public var windDeg: Int16
    @NSManaged public var windSpeed: Double
    @NSManaged public var weatherData: WeatherData?
    @NSManaged public var weather: NSSet?

}

// MARK: Generated accessors for weather
extension HourData {

    @objc(addWeatherObject:)
    @NSManaged public func addToWeather(_ value: WeatherElementData)

    @objc(removeWeatherObject:)
    @NSManaged public func removeFromWeather(_ value: WeatherElementData)

    @objc(addWeather:)
    @NSManaged public func addToWeather(_ values: NSSet)

    @objc(removeWeather:)
    @NSManaged public func removeFromWeather(_ values: NSSet)

}

extension HourData : Identifiable {

}
