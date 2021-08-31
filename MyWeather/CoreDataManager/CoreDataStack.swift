//
//  CoreDataStack.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 16.06.2021.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    static var persistentStoreContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError()
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return CoreDataStack.persistentStoreContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return CoreDataStack.persistentStoreContainer.newBackgroundContext()
    }
    
    func save(context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges {
                 do {
                     try context.save()
                 } catch {
                     print(error.localizedDescription)
                 }
             }
        }
    }
    
    func createObject<CW: NSManagedObject> (from entity: CW.Type, with context: NSManagedObjectContext) -> CW {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! CW
        return object
    }
    
    func delete(object: NSManagedObject, with context: NSManagedObjectContext) {
        context.delete(object)
        save(context: context)
    }
    
    func fetchData<CW: NSManagedObject>(for entity: CW.Type, with context: NSManagedObjectContext) -> [CW] {
        let request = entity.fetchRequest() as! NSFetchRequest<CW>
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data from context")
            fatalError()
        }
    }
    
    func fetchDataWithRequest<CW: NSManagedObject>(for entity: CW.Type, with context: NSManagedObjectContext, request: NSFetchRequest<CW>) -> [CW] {
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data from context")
            fatalError()
        }
    }
    
    /// обновляет данные о погоде для указанного города и возвращает объект CityWeather (город с содержащимися в нем данными о погоде)
    func updateWeather(for city: CityWeather, with weather: Weather) -> CityWeather {
        
        let updatedWeather = WeatherData(context: self.context)
        updatedWeather.lat = weather.lat
        updatedWeather.lon = weather.lon
        updatedWeather.timezone = weather.timezone
        updatedWeather.timezoneOffset = weather.timezoneOffset
        
        updatedWeather.city = city
        
        // current:
        let current = CurrentData(context: self.context)
        
        current.clouds = Int16(weather.current.clouds)
        current.dewPoint = weather.current.dewPoint
        current.dt = weather.current.dt
        current.feelsLike = weather.current.feelsLike
        current.humidity = Int16(weather.current.humidity)
        current.pressure = Int16(weather.current.pressure)
        current.sunrise = weather.current.sunrise
        current.sunset = weather.current.sunset
        current.temp = weather.current.temp
        current.uvi = weather.current.uvi
        current.visibility = Int16(weather.current.visibility)
        current.windDeg = Int16(weather.current.windDeg)
        current.windSpeed = weather.current.windSpeed
        current.weatherData = updatedWeather
        
        updatedWeather.current = current
        
        // current.weather:
        for weatherElement in weather.current.weather {
            let newWeatherElement = WeatherElementData(context: self.context)
            newWeatherElement.id = Int16(weatherElement.id)
            newWeatherElement.weatherDescription = weatherElement.weatherDescription
            newWeatherElement.currentData = updatedWeather.current
        }
        
        // weather.hourly
        for hourData in weather.hourly {
            let newHourData = HourData(context: self.context)
            newHourData.clouds = Int16(hourData.clouds)
            newHourData.dewPoint = hourData.dewPoint
            newHourData.dt = Int32(hourData.dt)
            newHourData.feelsLike = hourData.feelsLike
            newHourData.humidity = Int16(hourData.humidity)
            newHourData.pop = hourData.pop
            newHourData.pressure = Int16(hourData.pressure)
            newHourData.temp = hourData.temp
            newHourData.uvi = hourData.uvi
            newHourData.visibility = Int16(hourData.visibility)
            newHourData.windDeg = Int16(hourData.windDeg)
            newHourData.windSpeed = hourData.windSpeed
            newHourData.weatherData = updatedWeather
            
            for weatherElement in hourData.weather {
                let newWeatherElement = WeatherElementData(context: self.context)
                newWeatherElement.id = Int16(weatherElement.id)
                newWeatherElement.weatherDescription = weatherElement.weatherDescription
                newWeatherElement.hourData = newHourData
            }
        }
        
        // weather.daily
        for dayData in weather.daily {
            let newDayData = DayData(context: self.context)
            newDayData.clouds = Int16(dayData.clouds)
            newDayData.dewPoint = dayData.dewPoint
            newDayData.dt = dayData.dt
            newDayData.humidity = Int16(dayData.humidity)
            newDayData.moonPhase = dayData.moonPhase
            newDayData.moonrise = dayData.moonrise
            newDayData.moonset = dayData.moonset
            newDayData.pop = dayData.pop
            newDayData.pressure = Int16(dayData.pressure)
            if let rain = dayData.rain {
                newDayData.rain = rain
            }
            if let snow = dayData.snow {
                newDayData.snow = snow
            }
            newDayData.sunrise = dayData.sunrise
            newDayData.sunset = dayData.sunset
            newDayData.uvi = dayData.uvi
            newDayData.windDeg = Int16(dayData.windDeg)
            newDayData.windSpeed = dayData.windSpeed
            newDayData.weatherData = updatedWeather
            // temp
            let temp = TempData(context: self.context)
            temp.day = dayData.temp.day
            temp.eve = dayData.temp.eve
            temp.max = dayData.temp.max
            temp.min = dayData.temp.min
            temp.morn = dayData.temp.morn
            temp.night = dayData.temp.night
            temp.dayData = newDayData
            
            newDayData.temp = temp
            
            // feelsLike
            let feelsLike = FeelsLikeData(context: self.context)
            feelsLike.day = dayData.feelsLike.day
            feelsLike.eve = dayData.feelsLike.eve
            feelsLike.morn = dayData.feelsLike.morn
            feelsLike.night = dayData.feelsLike.night
            feelsLike.dayData = newDayData
            
            newDayData.feelsLike = feelsLike
            
            // weather
            for weatherElement in dayData.weather {
                let newWeatherElement = WeatherElementData(context: self.context)
                newWeatherElement.id = Int16(weatherElement.id)
                newWeatherElement.weatherDescription = weatherElement.weatherDescription
                newWeatherElement.dayData = newDayData
            }
            
        }
        
        // save
        if let cityObject = try? self.context.existingObject(with: city.objectID) as? CityWeather {
            cityObject.weather = updatedWeather
            
            save(context: self.context)
            
            return cityObject
        } else {
            print("Что-то пошло не так, невозможно обновить данные для города")
            return CityWeather()
        }
        
    }
}
