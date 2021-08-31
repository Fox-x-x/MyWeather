//
//  DayNightView.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.08.2021.
//

import Foundation
import UIKit
import Hex

final class DayNightView: UIView {
    
    var isInNightMode = false
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    var dayTimeName: String? {
        didSet {
            guard let dayTimeName = dayTimeName else { return }
            titleLabel.text = dayTimeName
        }
    }
    
    var dayCached: DayCached? {
        didSet {
            guard let dayCached = dayCached else { return }
            
            if let weatherID = dayCached.weather.first?.id {
                let imageName = getImageByWeatherID(id: weatherID)
                weatherConditionImage.image = UIImage(named: imageName)
            }
            
            if isInNightMode {
                if let nightTemp = dayCached.temp.night {
                    temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(nightTemp, to: options.temperature))) + "°"
                }
            } else {
                if let dayTemp = dayCached.temp.day {
                    temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(dayTemp, to: options.temperature))) + "°"
                }
            }
            
            weatherConditionLabel.text = dayCached.weather.first?.weatherDescription
            
            if isInNightMode {
                if let feelsLikeNightTemperature = dayCached.feelsLike.night {
                    feelsLikeSection.value = String(format: "%.0f", floor(convertTemperature(feelsLikeNightTemperature, to: options.temperature))) + "°"
                }
            } else {
                if let feelsLikeTemperature = dayCached.feelsLike.day {
                    feelsLikeSection.value = String(format: "%.0f", floor(convertTemperature(feelsLikeTemperature, to: options.temperature))) + "°"
                }
            }
            
            windSection.value = String(format: "%.0f", floor(convertWindSpeed(dayCached.windSpeed, to: options.winSpeed))) + " м/с"
            UVIndexSection.value = String(dayCached.uvi)
            rainSection.value = String(format: "%.0f", floor(dayCached.pop * 100)) + "%"
            cloudsSection.value = String(dayCached.clouds) + "%"
        }
    }
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            
            if let weatherID = day.weather.first?.id {
                let imageName = getImageByWeatherID(id: weatherID)
                weatherConditionImage.image = UIImage(named: imageName)
            }
            
            if isInNightMode {
                temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(day.temp.night, to: options.temperature))) + "°"
            } else {
                temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(day.temp.day, to: options.temperature))) + "°"
            }
            
            weatherConditionLabel.text = day.weather.first?.weatherDescription
            
            if isInNightMode {
                feelsLikeSection.value = String(format: "%.0f", floor(convertTemperature(day.feelsLike.night, to: options.temperature))) + "°"
            } else {
                feelsLikeSection.value = String(format: "%.0f", floor(convertTemperature(day.feelsLike.day, to: options.temperature))) + "°"
            }
            
            windSection.value = String(format: "%.0f", floor(convertWindSpeed(day.windSpeed, to: options.winSpeed))) + " м/с"
            UVIndexSection.value = String(day.uvi)
            rainSection.value = String(format: "%.0f", floor(day.pop * 100)) + "%"
            cloudsSection.value = String(day.clouds) + "%"
        }
    }
    
    // MARK: - Header section
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "День"
        return label
    }()
    
    private lazy var weatherConditionImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "--°"
        return label
    }()
    
    private lazy var weatherConditionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "--"
        return label
    }()
    
    // MARK: - Weather conditions section
    
    private lazy var feelsLikeSection: DayNightSectionView = {
        let view = DayNightSectionView()
        view.imageName = "feels-like"
        view.conditionName = "По ощущениям"
        view.value = "--°"
        return view
    }()
    
    private lazy var windSection: DayNightSectionView = {
        let view = DayNightSectionView()
        view.imageName = "wind"
        view.conditionName = "Ветер"
        view.value = "--"
        return view
    }()
    
    private lazy var UVIndexSection: DayNightSectionView = {
        let view = DayNightSectionView()
        view.imageName = "sunny"
        view.conditionName = "Уф индекс"
        view.value = "--"
        return view
    }()
    
    private lazy var rainSection: DayNightSectionView = {
        let view = DayNightSectionView()
        view.imageName = "rainy-cloud"
        view.conditionName = "Дождь"
        view.value = "--%"
        return view
    }()
    
    private lazy var cloudsSection: DayNightSectionView = {
        let view = DayNightSectionView()
        view.imageName = "cloudy-blue"
        view.conditionName = "Облачность"
        view.value = "--%"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        
        backgroundColor = UIColor(hex: "#E9EEFA")
        layer.cornerRadius = 5
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(21)
            make.leading.equalToSuperview().offset(15)
        }
        
        addSubview(weatherConditionImage)
        
        weatherConditionImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview().offset(-36)
            make.width.equalTo(24)
            make.height.equalTo(30)
        }
        
        addSubview(temperatureLabel)
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalTo(weatherConditionImage.snp.trailing).offset(10)
            
        }
        
        addSubview(weatherConditionLabel)
        
        weatherConditionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        addSubview(feelsLikeSection)
        
        feelsLikeSection.snp.makeConstraints { make in
            make.top.equalTo(weatherConditionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
        addSubview(windSection)
        
        windSection.snp.makeConstraints { make in
            make.top.equalTo(feelsLikeSection.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
        addSubview(UVIndexSection)
        UVIndexSection.snp.makeConstraints { make in
            make.top.equalTo(windSection.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
        addSubview(rainSection)
        rainSection.snp.makeConstraints { make in
            make.top.equalTo(UVIndexSection.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
        addSubview(cloudsSection)
        cloudsSection.snp.makeConstraints { make in
            make.top.equalTo(rainSection.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
    }
    
}
