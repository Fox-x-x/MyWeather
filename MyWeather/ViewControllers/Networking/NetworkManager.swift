//
//  NetworkManager.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.06.2021.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather)
    func didFailWithError(error: Error)
}

struct NetworkManager {
    
    var delegate: WeatherManagerDelegate?
    
    let session = URLSession.shared
    
    func fetchWeather() {
        performRequest()
    }
    
     func performRequest() {
        
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=33.44&lon=-94.04&lang=ru&units=metric&appid=4aa31e68b72635e6c5bd2e40781e5469") {
            let _ = session.dataTask(with: url) { (data, response, error) in
                
                guard error == nil else {
                    print("dataTask error:\n \(error.debugDescription)")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let data = data {
                    if let weather = self.parseJSON(data) {
                        print("Weather: \(weather)")
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
                
            }.resume()
        }
          
    }
    
    func parseJSON(_ weatherData: Data) -> Weather? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Weather.self, from: weatherData)
            return decodedData
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

}
