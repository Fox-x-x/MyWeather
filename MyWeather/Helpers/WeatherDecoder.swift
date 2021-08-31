//
//  WeatherDecoder.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 07.07.2021.
//

import Foundation
import CoreData

final class WeatherDecoder {
    
    func fromDataBase(weatherFromDB: WeatherData, coreDataManager: CoreDataStack) -> WeatherCached {
        
        var weatherElementsForCurrent = [WeatherElementCached]()
        
        var currentCached = CurrentDataCached(dt: nil, sunrise: nil, sunset: nil, temp: nil, feelsLike: nil, pressure: nil, humidity: nil, dewPoint: nil, uvi: nil, clouds: nil, visibility: nil, windSpeed: nil, windDeg: nil, weather: nil)
        
        var hoursCached = [HourCached]()
        var daysCached = [DayCached]()
        var tempForDayCached = TempCached(day: nil, min: nil, max: nil, night: nil, eve: nil, morn: nil)
        var feelsLikeForDay = FeelsLikeCached(day: nil, night: nil, eve: nil, morn: nil)
        
        // current
        let requestForCurrent: NSFetchRequest<CurrentData> = CurrentData.fetchRequest()
        let predicateForCurrent = NSPredicate(format: "weatherData == %@", weatherFromDB)
        requestForCurrent.predicate = predicateForCurrent
        let currentElements = coreDataManager.fetchDataWithRequest(for: CurrentData.self, with: coreDataManager.context, request: requestForCurrent)
        
        // массив weather для current
        if let current = currentElements.first {
            let requestForCurrentWeatherElements: NSFetchRequest<WeatherElementData> = WeatherElementData.fetchRequest()
            let predicateForCurrentWeatherElements = NSPredicate(format: "currentData == %@", current)
            requestForCurrentWeatherElements.predicate = predicateForCurrentWeatherElements
            let currentWeatherElements = coreDataManager.fetchDataWithRequest(for: WeatherElementData.self, with: coreDataManager.context, request: requestForCurrentWeatherElements)
            
            for weatherElement in currentWeatherElements {
                let weather = WeatherElementCached(id: Int(weatherElement.id), weatherDescription: weatherElement.weatherDescription)
                weatherElementsForCurrent.append(weather)
            }
            
            let newCurrentCached = CurrentDataCached(dt: current.dt,
                               sunrise: current.sunrise,
                               sunset: current.sunset,
                               temp: current.temp,
                               feelsLike: current.feelsLike,
                               pressure: Int(current.pressure),
                               humidity: Int(current.humidity),
                               dewPoint: current.dewPoint,
                               uvi: current.uvi,
                               clouds: Int(current.clouds),
                               visibility: Int(current.visibility),
                               windSpeed: current.windSpeed,
                               windDeg: Int(current.windDeg),
                               weather: weatherElementsForCurrent
            )
            
            currentCached = newCurrentCached
            
        }
        
        // Подумать про то, что некоторых параметров может не прилетать в ответе сервера
        // Поделать запросы на пупырловки и посмотреть что от них прилетает. Может сделать все поля optional?
        
        // hour
        let requestForHour: NSFetchRequest<HourData> = HourData.fetchRequest()
        let predicateForHour = NSPredicate(format: "weatherData == %@", weatherFromDB)
        requestForHour.predicate = predicateForHour
        let hourSortDescriptor = NSSortDescriptor(key: "dt", ascending: true)
        requestForHour.sortDescriptors = [hourSortDescriptor]
        let hourElements = coreDataManager.fetchDataWithRequest(for: HourData.self, with: coreDataManager.context, request: requestForHour)
        
        // hour weatherElements
        // создаем массив hourCached, в цикле создаем элемент hourCached и запихиваем в него полученные при запросе в цикле WeatherElementCached
        for hour in hourElements {
            
            let requestForHourWeatherElements: NSFetchRequest<WeatherElementData> = WeatherElementData.fetchRequest()
            let predicateForHourWeatherElements = NSPredicate(format: "hourData == %@", hour)
            requestForHourWeatherElements.predicate = predicateForHourWeatherElements
            let hourWeatherElements = coreDataManager.fetchDataWithRequest(for: WeatherElementData.self, with: coreDataManager.context, request: requestForHourWeatherElements)
            
            var weatherElementsForHour = [WeatherElementCached]()
            
            for weatherElement in hourWeatherElements {
                let weather = WeatherElementCached(id: Int(weatherElement.id), weatherDescription: weatherElement.description)
                weatherElementsForHour.append(weather)
            }
            
            let hourCached = HourCached(dt: Int(hour.dt),
                                        temp: hour.temp,
                                        feelsLike: hour.feelsLike,
                                        pressure: Int(hour.pressure),
                                        humidity: Int(hour.humidity),
                                        dewPoint: hour.dewPoint,
                                        uvi: hour.uvi,
                                        clouds: Int(hour.clouds),
                                        visibility: Int(hour.visibility),
                                        windSpeed: hour.windSpeed,
                                        windDeg: Int(hour.windDeg),
                                        pop: hour.pop,
                                        weather: weatherElementsForHour
            )
            
            hoursCached.append(hourCached)
            
        }
        
        // day -- проделать то же самое, что и с hour выше
        let requestForDay: NSFetchRequest<DayData> = DayData.fetchRequest()
        let predicateForDay = NSPredicate(format: "weatherData == %@", weatherFromDB)
        requestForDay.predicate = predicateForDay
        let daySortDescriptor = NSSortDescriptor(key: "dt", ascending: true)
        requestForDay.sortDescriptors = [daySortDescriptor]
        let dayElements = coreDataManager.fetchDataWithRequest(for: DayData.self, with: coreDataManager.context, request: requestForDay)
        
        for day in dayElements {
            // temp
            let requestForTemp: NSFetchRequest<TempData> = TempData.fetchRequest()
            let predicateForTemp = NSPredicate(format: "dayData == %@", day)
            requestForTemp.predicate = predicateForTemp
            let tempElements = coreDataManager.fetchDataWithRequest(for: TempData.self, with: coreDataManager.context, request: requestForTemp)
            
            if let tempElement = tempElements.first {
                let temp = TempCached(day: tempElement.day,
                                      min: tempElement.min,
                                      max: tempElement.max,
                                      night: tempElement.night,
                                      eve: tempElement.eve,
                                      morn: tempElement.morn
                )
                
                tempForDayCached = temp
            }
            
            // feelslike
            let requestForFeelsLikeData: NSFetchRequest<FeelsLikeData> = FeelsLikeData.fetchRequest()
            let predicateForFeelsLikeData = NSPredicate(format: "dayData == %@", day)
            requestForFeelsLikeData.predicate = predicateForFeelsLikeData
            let FeelsLikeElements = coreDataManager.fetchDataWithRequest(for: FeelsLikeData.self, with: coreDataManager.context, request: requestForFeelsLikeData)
            
            if let feelsLikeElement = FeelsLikeElements.first {
                let feelsLike = FeelsLikeCached(day: feelsLikeElement.day,
                                                night: feelsLikeElement.night,
                                                eve: feelsLikeElement.eve,
                                                morn: feelsLikeElement.morn
                )
                
                feelsLikeForDay = feelsLike
            }
            
            
            // weatherElements for weather
            let requestForDayWeatherElements: NSFetchRequest<WeatherElementData> = WeatherElementData.fetchRequest()
            let predicateForDayWeatherElements = NSPredicate(format: "dayData == %@", day)
            requestForDayWeatherElements.predicate = predicateForDayWeatherElements
            let dayWeatherElements = coreDataManager.fetchDataWithRequest(for: WeatherElementData.self, with: coreDataManager.context, request: requestForDayWeatherElements)
            
            var weatherElementsForDay = [WeatherElementCached]()
            
            for weatherElement in dayWeatherElements {
                let weather = WeatherElementCached(id: Int(weatherElement.id), weatherDescription: weatherElement.weatherDescription)
                weatherElementsForDay.append(weather)
            }
            
            let newDay = DayCached(dt: day.dt,
                                   sunrise: day.sunrise,
                                   sunset: day.sunset,
                                   moonrise: day.moonrise,
                                   moonset: day.moonset,
                                   moonPhase: day.moonPhase,
                                   temp: tempForDayCached,
                                   feelsLike: feelsLikeForDay,
                                   pressure: Int(day.pressure),
                                   humidity: Int(day.humidity),
                                   dewPoint: day.dewPoint,
                                   windSpeed: day.windSpeed,
                                   windDeg: Int(day.windDeg),
                                   weather: weatherElementsForDay,
                                   clouds: Int(day.clouds),
                                   pop: day.pop,
                                   uvi: day.uvi,
                                   rain: day.rain,
                                   snow: day.snow
            )
            
            daysCached.append(newDay)
            
        }
        
        
        let weather = WeatherCached(lat: weatherFromDB.lat,
                                    lon: weatherFromDB.lon,
                                    timezone: weatherFromDB.timezone,
                                    timezoneOffset: weatherFromDB.timezoneOffset,
                                    current: currentCached,
                                    hourly: hoursCached,
                                    daily: daysCached
        )
        
        return weather
        
    }
    
    private func fromNetwork() {
        
    }
    
}
