//
//  NetworkManager.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.06.2021.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather)
    func didFailWithError(error: Error)
    func didBeginNetworkActivity()
}

protocol FindCityLocationManagerDelegate {
    func didReceiveCityData(_ cityLocationManager: NetworkManager, cityData: City)
    func didFailWithError(error: Error)
}

final class NetworkManager {

    let apiKey = "4aa31e68b72635e6c5bd2e40781e5469"
    let unitsOfMeasurement = "metric"
    let lang = "ru"
    
    var weatherDataDelegate: WeatherManagerDelegate?
    var cityLocationDelegate: FindCityLocationManagerDelegate?
    
    let session = URLSession.shared
    
    private lazy var urlComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/onecall"
        
        return components
    }()
    
    func fetchWeather(for city: CityWeather) {
        
        urlComponents.queryItems = []
        urlComponents.queryItems = [
            URLQueryItem(name: "lang", value: lang),
            URLQueryItem(name: "units", value: unitsOfMeasurement),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lat", value: city.lat),
            URLQueryItem(name: "lon", value: city.lon)
        ]
        
        let url = urlComponents.url?.absoluteString
        
        weatherDataDelegate?.didBeginNetworkActivity()
        
        if let url = url {
            performWeatherUpdateRequest(url: url)
        } else {
            weatherDataDelegate?.didFailWithError(error: ApiError.networkError)
        }

    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        
        urlComponents.queryItems = []
        urlComponents.queryItems = [
            URLQueryItem(name: "lang", value: lang),
            URLQueryItem(name: "units", value: unitsOfMeasurement),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon))
        ]

        let url = urlComponents.url?.absoluteString
        
        weatherDataDelegate?.didBeginNetworkActivity()
        
        if let url = url {
            performWeatherUpdateRequest(url: url)
        } else {
            weatherDataDelegate?.didFailWithError(error: ApiError.networkError)
        }
        
    }
    
    func fetchCityLocation(cityName city: String) {
        let url = "https://geocode-maps.yandex.ru/1.x/?apikey=ce5980d1-ab1f-4024-826c-d5e9a5726970&geocode=" + city + "&results=1&format=json"
        performRequest(with: url) { [weak self] result in
            if let vc = self {
                switch result {
                case .success(let data):
                    if let city = vc.parseJSON(location: data) {
                        vc.cityLocationDelegate?.didReceiveCityData(vc, cityData: city)
                    }
                case .failure(let error):
                    vc.cityLocationDelegate?.didFailWithError(error: error)
                }
            }
        }
        
    }
    
    func performRequest(with url: String, completion: @escaping (Result<Data, ApiError>) -> Void) {
        
        guard let cyrillicURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        if let url = URL(string: cyrillicURL) {
            
            let queue = DispatchQueue.global(qos: .userInitiated)
            
            queue.async {
                let task = self.session.dataTask(with: url) { data, response, error in
                    
                    guard error == nil else {
                        completion(.failure(.networkError))
                        return
                    }
                    
                    if let data = data {
                        print(data)
                        completion(.success(data))
                    }
                }
                task.resume()
                
            }
            
        }
          
    }
    
    /// парсит данные о погоде
    func parseJSON(weatherData data: Data) -> Weather? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Weather.self, from: data)
            return decodedData
            
        } catch {
            weatherDataDelegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    /// парсит данные о городе
    func parseJSON(location locationData: Data) -> City? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(City.self, from: locationData)
            return decodedData
        } catch {
            return nil
        }
    }
    
    func performWeatherUpdateRequest(url: String) {
        performRequest(with: url) { [weak self] result in
            if let vc = self {
                switch result {
                case .success(let data):
                    if let weather = vc.parseJSON(weatherData: data) {
                        vc.weatherDataDelegate?.didUpdateWeather(vc, weather: weather)
                    }
                case .failure(let error):
                    vc.weatherDataDelegate?.didFailWithError(error: error)
                }
            }
        }
    }

}
