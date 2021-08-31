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
    
//    func calculatePoints(view: UIView, cachedHours: [HourCached]?, hours: [Hour]?, isInCacheMode: Bool) -> [CGPoint] {
//        
//        let cachedHours = cachedHours?.prefix(7)
//        let hours = hours?.prefix(7)
//        
//        var points = [CGPoint]()
//        
//        let offset: CGFloat = 16
//        let daysNumber: CGFloat = 7
//        let bottomLine: Double = 55 // нижняя граница графика
//        
//        let width = view.bounds.width - offset * 2
//        let stepX = width / (daysNumber - 1) // линий должно быть на 1 меньше, чем дней
//        let h: Double = 25
//        
//        var maxT: Double = 0
//        var minT: Double = 0
//        
//        var k: Double = 0
//        
//        if isInCacheMode {
//            
//            if let hoursCached = cachedHours {
//                if let maxValue = hoursCached.max(by: { t1, t2 in
//                    t1.temp < t2.temp
//                })?.temp {
//                    maxT = maxValue
//                }
//                
//                if let minValue = hoursCached.min(by: { t1, t2 in
//                    t1.temp < t2.temp
//                })?.temp {
//                    minT = minValue
//                }
//                
//                k = h / (maxT - minT)
//                
//                var x: CGFloat = offset
//                
//                for hour in hoursCached {
//                    let y = CGFloat(bottomLine - (hour.temp - minT) * k + 2)
//                    let point = CGPoint(x: x, y: y)
//                    points.append(point)
//                    x = x + stepX
//                }
//            }
//            
//        } else {
//            
//            if let hours = hours {
//                if let maxValue = hours.max(by: { t1, t2 in
//                    t1.temp < t2.temp
//                })?.temp {
//                    maxT = maxValue
//                }
//                
//                if let minValue = hours.min(by: { t1, t2 in
//                    t1.temp < t2.temp
//                })?.temp {
//                    minT = minValue
//                }
//                
//                k = h / (maxT - minT)
//                
//                var x: CGFloat = offset
//                
//                for hour in hours {
//                    let y = CGFloat(bottomLine - (hour.temp - minT) * k + 2)
//                    let point = CGPoint(x: x, y: y)
//                    points.append(point)
//                    x = x + stepX
//                }
//            }
//        }
//        
//        return points
//
//    }
    
}
