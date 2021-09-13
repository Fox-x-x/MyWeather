//
//  CityWeather+CoreDataProperties.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 26.06.2021.
//
//

import Foundation
import CoreData


extension CityWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityWeather> {
        return NSFetchRequest<CityWeather>(entityName: "CityWeather")
    }
    
    @NSManaged public var geolocated: Bool
    @NSManaged public var cityName: String
    @NSManaged public var countryName: String
    @NSManaged public var lat: String
    @NSManaged public var lon: String
    @NSManaged public var weather: WeatherData?

}

extension CityWeather : Identifiable {

}
