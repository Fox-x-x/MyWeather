//
//  WeatherElementData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension WeatherElementData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherElementData> {
        return NSFetchRequest<WeatherElementData>(entityName: "WeatherElementData")
    }

    @NSManaged public var id: Int16
    @NSManaged public var weatherDescription: String
    @NSManaged public var currentData: CurrentData?
    @NSManaged public var hourData: HourData?
    @NSManaged public var dayData: DayData?

}

extension WeatherElementData : Identifiable {

}
