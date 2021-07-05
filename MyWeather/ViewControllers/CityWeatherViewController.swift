//
//  CityWeatherViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit
import Hex
import CoreData

class CityWeatherViewController: UIViewController {
    
    var weatherManager = NetworkManager()
    
    private var city: CityWeather
    
    private let coreDataManager = CoreDataStack()
    private lazy var context = coreDataManager.context
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var daySummaryView = DaySummaryView()
    
    private lazy var moreFor24HRSButton: UIButton = {
        
        let button = UIButton()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attributeString = NSMutableAttributedString(
            string: "Подробнее на 24 часа",
            attributes: attributes
        )
        
        button.setAttributedTitle(attributeString, for: .normal)

        button.addTarget(self, action: #selector(moreFor24HRSButtonPressed), for: .touchUpInside)
        return button
        
    }()
    
    private lazy var forecast24HRSCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            Forecast24HRSCell.self,
            forCellWithReuseIdentifier: String(describing: Forecast24HRSCell.self)
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var daylyForecastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "Ежедневный прогноз"
        return label
    }()
    
    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BriefWeatherInfoTableViewCell.self, forCellReuseIdentifier: String(describing: BriefWeatherInfoTableViewCell.self))
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    init(city: CityWeather) {
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        weatherManager.weatherDataDelegate = self
        weatherManager.cityLocationDelegate = self
        
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
//        print("Активируем город: \(city.cityName)")
        
        title = city.cityName
        
        if let weatherFromDB = city.weather {
            // обновляем UI данными из БД, конвертируем в Weather и суем в DaySummaryView
            print("Хочу обновиться из кэша :)")
        } else {
            // в противном случае делаем запрос в сеть и далее идем в метод делегата и там обновляем UI
            print("Иду в сеть...")
            weatherManager.fetchWeather(for: city)
        }
        
        
//        https://api.openweathermap.org/data/2.5/onecall?lat=54.43&lon=20.30&lang=ru&units=metric&appid=4aa31e68b72635e6c5bd2e40781e5469
//        weatherManager.fetchCityLocation(cityName: "https://geocode-maps.yandex.ru/1.x/?apikey=ce5980d1-ab1f-4024-826c-d5e9a5726970&geocode=%D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0&results=1&format=json")
    }
    
    private func setupLayout() {
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-32)
            make.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(daySummaryView)
        
        daySummaryView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(212)
        }
        
        contentView.addSubview(moreFor24HRSButton)
        
        moreFor24HRSButton.snp.makeConstraints { make in
            make.top.equalTo(daySummaryView.snp.bottom).offset(33)
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        contentView.addSubview(forecast24HRSCollectionView)
        
        forecast24HRSCollectionView.snp.makeConstraints { make in
            make.top.equalTo(moreFor24HRSButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        contentView.addSubview(daylyForecastLabel)
        
        daylyForecastLabel.snp.makeConstraints { make in
            make.top.equalTo(forecast24HRSCollectionView.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }
        
        contentView.addSubview(weatherTableView)
        
        weatherTableView.snp.makeConstraints { make in
            make.top.equalTo(daylyForecastLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 1.5)
            make.bottom.equalToSuperview()
        }
        
    }
    
    @objc private func moreFor24HRSButtonPressed() {
        print("24 hours")
    }
    
}

// MARK: - CollectionView extension

extension CityWeatherViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Forecast24HRSCell.self), for: indexPath) as! Forecast24HRSCell
        
        return cell
    }
    
}

extension CityWeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 42
        let height: CGFloat = 83
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

// MARK: - TableView extension

extension CityWeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BriefWeatherInfoTableViewCell.self), for: indexPath) as! BriefWeatherInfoTableViewCell
        
        return cell
    }
    
}

extension CityWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CityWeatherViewController: WeatherManagerDelegate {
    
    func didBeginNetworkActivity() {
        daySummaryView.spinner.startAnimating()
    }
    
    
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather) {
        DispatchQueue.main.async {
            // здесь прилетают данные о погоде для города. Берем эти данные и добаляем в city.weather в БД, т.е. обновляем данные в БД.
            // Потом передаем этот объект целиком в daySummaryView и там обновляем это View.
            // Т.е. получается, что данные о погоде на UI всегда будут обновляться из БД: при первом запуске и при обновлении по сети
            
            
            self.daySummaryView.weather = weather
            self.daySummaryView.spinner.stopAnimating()
            
            // записали в БД (для обновления из кэша в будущем)
            let updatedWeather = WeatherData(context: self.context)
            updatedWeather.lat = weather.lat
            updatedWeather.lon = weather.lon
            updatedWeather.timezone = weather.timezone
            updatedWeather.timezoneOffset = weather.timezoneOffset
            
            // нужно передать в этот контроллер контекст из предыдущего, чтобы нормально работать
            updatedWeather.city = self.city
            
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
            if let cityObject = try? self.context.existingObject(with: self.city.objectID) as? CityWeather {
                cityObject.weather = updatedWeather
                
                self.coreDataManager.save(context: self.context)
                
                self.city = cityObject
            }
            
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.daySummaryView.spinner.stopAnimating()
        }
    }
}

extension CityWeatherViewController: FindCityLocationManagerDelegate {
    func didReceiveCityData(_ cityLocationManager: NetworkManager, cityData: City) {
        
    }
    
    func didReceiveCityData(cityData: City) {
        
    }
    
    
}
