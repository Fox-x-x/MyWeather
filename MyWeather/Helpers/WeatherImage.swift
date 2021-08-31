//
//  WeatherImage.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 23.07.2021.
//

import Foundation

func getImageByWeatherID(id: Int) -> String {
    
    var imageName = ""
    
    switch id {
    
    case 200...232:
        imageName = "thunder"
    case 300...321:
        imageName = "rainy-cloud"
    case 500...531:
        imageName = "rainy-cloud"
    case 600...622:
        imageName = "snow"
    case 701...781:
        imageName = "fog"
    case 800:
        imageName = "sunny"
    case 801...804:
        imageName = "cloudy-blue"
    default:
        imageName = ""
        
    }
    
    return imageName
}
