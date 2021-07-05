//
//  TempData+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension TempData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempData> {
        return NSFetchRequest<TempData>(entityName: "TempData")
    }

    @NSManaged public var day: Double
    @NSManaged public var eve: Double
    @NSManaged public var max: Double
    @NSManaged public var min: Double
    @NSManaged public var morn: Double
    @NSManaged public var night: Double
    @NSManaged public var dayData: DayData

}

extension TempData : Identifiable {

}
