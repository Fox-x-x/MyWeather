//
//  FeelsLikeData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension FeelsLikeData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeelsLikeData> {
        return NSFetchRequest<FeelsLikeData>(entityName: "FeelsLikeData")
    }

    @NSManaged public var day: Double
    @NSManaged public var eve: Double
    @NSManaged public var morn: Double
    @NSManaged public var night: Double
    @NSManaged public var dayData: DayData

}

extension FeelsLikeData : Identifiable {

}
