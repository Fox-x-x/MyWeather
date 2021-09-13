//
//  PointsForChartCalculator.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 21.08.2021.
//

import Foundation
import UIKit
import Charts

extension UIViewController {
    
    func getPointsForChart(cachedHours: [HourCached]?, hours: [Hour]?, options: OptionsStack, isInCacheMode: Bool)  -> [ChartDataEntry] {
        
        let daysNumber = 7
        
        let cachedHours = cachedHours?.prefix(daysNumber) // возьмем только первые 7 дней, чтобы не загромождать
        let hours = hours?.prefix(daysNumber)
        
        var points = [ChartDataEntry]()
        
        var stepX: Double = 1 // условная координата первого дня на графике
        
        if isInCacheMode {
            if let cachedHours = cachedHours {
                for hour in cachedHours {
                    let x = stepX
                    let y = floor(convertTemperature(hour.temp, to: options.temperature))
                    let point = ChartDataEntry(x: x, y: y)
                    stepX += 1
                    points.append(point)
                }
            }
        } else {
            if let hours = hours {
                for hour in hours {
                    let x = stepX
                    let y = floor(convertTemperature(hour.temp, to: options.temperature))
                    let point = ChartDataEntry(x: x, y: y)
                    stepX += 1
                    points.append(point)
                }
            }
        }
        
        return points
        
    }
    
}
