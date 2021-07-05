//
//  WeatherData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension WeatherData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherData> {
        return NSFetchRequest<WeatherData>(entityName: "WeatherData")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var timezone: String?
    @NSManaged public var timezoneOffset: Double
    @NSManaged public var city: CityWeather
    @NSManaged public var current: CurrentData
    @NSManaged public var hourly: NSSet?
    @NSManaged public var daily: NSSet?

}

// MARK: Generated accessors for hourly
extension WeatherData {

    @objc(addHourlyObject:)
    @NSManaged public func addToHourly(_ value: HourData)

    @objc(removeHourlyObject:)
    @NSManaged public func removeFromHourly(_ value: HourData)

    @objc(addHourly:)
    @NSManaged public func addToHourly(_ values: NSSet)

    @objc(removeHourly:)
    @NSManaged public func removeFromHourly(_ values: NSSet)

}

// MARK: Generated accessors for daily
extension WeatherData {

    @objc(addDailyObject:)
    @NSManaged public func addToDaily(_ value: DayData)

    @objc(removeDailyObject:)
    @NSManaged public func removeFromDaily(_ value: DayData)

    @objc(addDaily:)
    @NSManaged public func addToDaily(_ values: NSSet)

    @objc(removeDaily:)
    @NSManaged public func removeFromDaily(_ values: NSSet)

}

extension WeatherData : Identifiable {

}
