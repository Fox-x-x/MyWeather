//
//  CurrentData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension CurrentData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentData> {
        return NSFetchRequest<CurrentData>(entityName: "CurrentData")
    }

    @NSManaged public var clouds: Int16
    @NSManaged public var dewPoint: Double
    @NSManaged public var dt: Double
    @NSManaged public var feelsLike: Double
    @NSManaged public var humidity: Int16
    @NSManaged public var pressure: Int16
    @NSManaged public var sunrise: Double
    @NSManaged public var sunset: Double
    @NSManaged public var temp: Double
    @NSManaged public var uvi: Double
    @NSManaged public var visibility: Int16
    @NSManaged public var windDeg: Int16
    @NSManaged public var windSpeed: Double
    @NSManaged public var weatherData: WeatherData?
    @NSManaged public var weather: [WeatherElementData]

}

// MARK: Generated accessors for weather
extension CurrentData {

    @objc(addWeatherObject:)
    @NSManaged public func addToWeather(_ value: WeatherElementData)

    @objc(removeWeatherObject:)
    @NSManaged public func removeFromWeather(_ value: WeatherElementData)

    @objc(addWeather:)
    @NSManaged public func addToWeather(_ values: NSSet)

    @objc(removeWeather:)
    @NSManaged public func removeFromWeather(_ values: NSSet)

}

extension CurrentData : Identifiable {

}
