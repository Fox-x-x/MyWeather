//
//  OptionsStorage.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 23.05.2021.
//

import Foundation

struct OptionsStorage {
    
    static let options = [
        Option(title: "Температура", values: ["C", "F"]),
        Option(title: "Скорость ветра", values: ["Mi", "Km"]),
        Option(title: "Формат времени", values: ["12", "24"]),
        Option(title: "Уведомления", values: ["On", "Off"])
    ]
    
}
