//
//  UNIXDateToString.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 07.06.2021.
//

import Foundation
import UIKit

extension UIView {
    
    /// конвертирует дату в формате Date в строку
    func dateToString(_ date: Double, withFormat format: String) -> String {
        
        let calcDate = Date(timeIntervalSince1970: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter.string(from: calcDate)
    }
    
    /// конвертирует дату в формате Date в строку  с выбранным dateStyle
    func dateToString(_ date: Date, withFormat format: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = format
        
        return dateFormatter.string(from: date)
    }
}
