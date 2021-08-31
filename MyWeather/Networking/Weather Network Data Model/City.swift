//
//  GeoObject.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 11.06.2021.
//

import Foundation

// От Яндекса приходит JSON с очень глубокой вложенностью в него координат объекта.
// Чтобы не плодить кучу файлов, занес всю структуру с подструктурами в один файл.
// Если делать грязь, то в одном файле :))
public final class City: Codable {
    
    let response: geoObjectResponse
}

struct geoObjectResponse: Codable {
    let geoObjectCollection: geoObjectCollection

    enum CodingKeys: String, CodingKey {
        case geoObjectCollection = "GeoObjectCollection"
    }
}

struct geoObjectCollection: Codable {
    let featureMember: [geoObjectFeatureMember]
}

struct geoObjectFeatureMember: Codable {
    let geoObject: geoObject

    enum CodingKeys: String, CodingKey {
        case geoObject = "GeoObject"
    }
}

struct geoObject: Codable {
    let city, country: String
    
    var lat: String {
        get {
            return getGeoPointCoordinate(from: point, for: .lat)
        }
    }
    
    var lon: String {
        get {
            return getGeoPointCoordinate(from: point, for: .lon)
        }
    }
    
    let point: geoObjectPoint

    enum CodingKeys: String, CodingKey {
        case city = "name"
        case country = "description"
        case point = "Point"
    }
    
    enum coordinatesNames {
        case lat
        case lon
    }
    
    /// парсит строку от сервера с координатами в одной строке на 2 отдельные строки с широтой и доготой
    private func getGeoPointCoordinate(from point: geoObjectPoint, for coordinateName: coordinatesNames) -> String {
        let points = point.pos.split(separator: " ")
        if points.count == 2 {
            if coordinateName == .lat {
                return String(points[1])
            } else {
                return String(points[0])
            }
        }
        return ""
    }
    
}

struct geoObjectPoint: Codable {
    let pos: String
}






