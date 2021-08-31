//
//  DaySummaryView.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 30.05.2021.
//

import UIKit
import SnapKit

final class DaySummaryView: UIView {
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    var weather: Weather? {
        didSet {
            guard let weather = weather else { return }
            
            dayNightTemperatureLabel.text = String(format: "%.0f", floor(convertTemperature(weather.daily[0].temp.day, to: options.temperature))) + "°/" + String(format: "%.0f", floor(convertTemperature(weather.daily[0].temp.night, to: options.temperature)) ) + "°"
            currentTemperatureLabel.text = String(format: "%.0f", floor(convertTemperature(weather.current.temp, to: options.temperature))) + "°"
            downfallTitleLabel.text = String(weather.current.weather[0].weatherDescription)
            
            if let rainMetric = weather.daily[0].rain {
                downfallMetricLabel.text = String(format: "%.0f", floor(rainMetric))
            } else if let snowMetric = weather.daily[0].snow {
                downfallMetricLabel.text = String(format: "%.0f", floor(snowMetric))
            } else {
                downfallMetricLabel.text = "0"
            }
            
            windMetricLabel.text = String(format: "%.0f", floor(convertWindSpeed(weather.current.windSpeed, to: options.winSpeed))) + " м/с"
            rainMetricLabel.text = String(format: "%.0f", floor(weather.daily[0].pop * 100)) + "%"
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h:mm a"
            }
            sunriseTimeLabel.text = dateToString(weather.current.sunrise + weather.timezoneOffset, withFormat: timeFormat)
            sunsetTimeLabel.text = dateToString(weather.current.sunset + weather.timezoneOffset, withFormat: timeFormat)
            
            dateLabel.text = dateToString(weather.current.dt + weather.timezoneOffset, withFormat: timeFormat + ", E dd MMM")
            
        }
    }
    
    var weatherFromDB: WeatherCached? {
        didSet {
            guard let weatherFromDB = weatherFromDB else { return }
            
            if let dayTemp = weatherFromDB.daily[0].temp.day, let nightTemp = weatherFromDB.daily[0].temp.night {
                dayNightTemperatureLabel.text = String(format: "%.0f", floor(convertTemperature(dayTemp, to: options.temperature))) + "°/" + String(format: "%.0f", floor(convertTemperature(nightTemp, to: options.temperature)) ) + "°"
            }
            
            if let currentTemp = weatherFromDB.current.temp {
                currentTemperatureLabel.text = String(format: "%.0f", floor(convertTemperature(currentTemp, to: options.temperature))) + "°"
            }
            
            if let weatherElements = weatherFromDB.current.weather {
                downfallTitleLabel.text = String(weatherElements[0].weatherDescription)
            }
            
            if let rainMetric = weatherFromDB.daily[0].rain {
                downfallMetricLabel.text = String(format: "%.0f", floor(rainMetric))
            } else if let snowMetric = weatherFromDB.daily[0].snow {
                downfallMetricLabel.text = String(format: "%.0f", floor(snowMetric))
            } else {
                downfallMetricLabel.text = "0"
            }
            
            if let windSpeed = weatherFromDB.current.windSpeed {
                windMetricLabel.text = String(format: "%.0f", floor(convertWindSpeed(windSpeed, to: options.winSpeed))) + " м/с"
            }
            
            rainMetricLabel.text = String(format: "%.0f", floor(weatherFromDB.daily[0].pop * 100)) + "%"
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h:mm a"
            }
            
            if let sunrise = weatherFromDB.current.sunrise {
                sunriseTimeLabel.text = dateToString(sunrise + weatherFromDB.timezoneOffset, withFormat: timeFormat)
            }
            
            if let sunset = weatherFromDB.current.sunset {
                sunsetTimeLabel.text = dateToString(sunset + weatherFromDB.timezoneOffset, withFormat: timeFormat)
            }
            
            if let dt = weatherFromDB.current.dt {
                dateLabel.text = dateToString(dt + weatherFromDB.timezoneOffset, withFormat: timeFormat + ", E dd MMM")
            }
            
        }
    }
    
    // MARK: - UI Elements: Header
    private lazy var daySummaryContentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#204EC7")
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var dayDurationArcImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Ellipse")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .medium
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private lazy var dayNightTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 1
        label.text = "-°/-°"
        return label
    }()
    
    lazy var currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 1
        label.text = "-°"
        return label
    }()
    
    private lazy var downfallTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "нет данных для города"
        return label
    }()
    
    // MARK: - UI Elements: Header: metric labels and icons
    
    // MARK: - downfall in mm
    private lazy var downfallMetricView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var cloudyImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "cloudy")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var downfallMetricLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 1
        label.text = "-"
        return label
    }()
    
    // MARK: - wind
    private lazy var windMetricView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var windImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "wind")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var windMetricLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 1
        label.text = "- м/с"
        return label
    }()
    
    // MARK: - chance of rain in %
    private lazy var rainMetricView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var rainDropsImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rain-drops")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var rainMetricLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 1
        label.text = "--%"
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#F6DD01")
        label.numberOfLines = 1
        label.text = "--"
        return label
    }()
    
    // MARK: - sunrise and sunset
    private lazy var sunriseImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "sunrise")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var sunsetImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "sunset")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var sunriseTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(hex: "#FFFFFF")
        label.numberOfLines = 1
        label.text = "--:--"
        return label
    }()
    
    private lazy var sunsetTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(hex: "#FFFFFF")
        label.numberOfLines = 1
        label.text = "--:--"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        
        addSubview(daySummaryContentView)
        
        daySummaryContentView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        daySummaryContentView.addSubview(dayDurationArcImage)
        
        dayDurationArcImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(125)
        }
        
        daySummaryContentView.addSubview(spinner)
        
        spinner.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        daySummaryContentView.addSubview(dayNightTemperatureLabel)
        
        dayNightTemperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(33)
            make.centerX.equalToSuperview()
        }
        
        daySummaryContentView.addSubview(currentTemperatureLabel)
        
        currentTemperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(58)
            make.centerX.equalToSuperview()
        }
        
        daySummaryContentView.addSubview(downfallTitleLabel)
        
        downfallTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(103)
            make.centerX.equalToSuperview()
            make.width.equalTo(230)
        }
        
        // downfall
        daySummaryContentView.addSubview(downfallMetricView)
        downfallMetricView.addSubviews(cloudyImage, downfallMetricLabel)
        
        cloudyImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(18)
            make.bottom.equalToSuperview()
        }
        downfallMetricLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(cloudyImage.snp.trailing).offset(3)
            make.trailing.equalToSuperview()
            make.width.equalTo(20)
        }
        
        // wind
        windMetricView.addSubviews(windImage, windMetricLabel)

        windImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(18)
            make.bottom.equalToSuperview()
        }
        windMetricLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(windImage.snp.trailing).offset(3)
            make.trailing.equalToSuperview()
            make.width.equalTo(45)
        }
        
        // rain
        rainMetricView.addSubviews(rainDropsImage, rainMetricLabel)
        
        rainDropsImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(18)
            make.bottom.equalToSuperview()
        }
        rainMetricLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(rainDropsImage.snp.trailing).offset(3)
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
        }
        
        let dayMetricsStackView = UIStackView(arrangedSubviews: [downfallMetricView, windMetricView, rainMetricView])
        dayMetricsStackView.axis = .horizontal
        dayMetricsStackView.distribution = .equalSpacing
        dayMetricsStackView.spacing = 10
        
        daySummaryContentView.addSubview(dayMetricsStackView)
        
        dayMetricsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(136)
            make.centerX.equalToSuperview()
        }
        
        // date
        daySummaryContentView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(171)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-21)
        }
        
        // sunrise and sunset
        daySummaryContentView.addSubviews(sunriseImage, sunsetImage)
        
        sunriseImage.snp.makeConstraints { make in
            make.top.equalTo(dayDurationArcImage.snp.bottom).offset(2)
            make.leading.equalTo(dayDurationArcImage.snp.leading).offset(-8)
            make.width.equalTo(17)
            make.height.equalTo(17)
        }
        
        sunsetImage.snp.makeConstraints { make in
            make.top.equalTo(dayDurationArcImage.snp.bottom).offset(2)
            make.trailing.equalTo(dayDurationArcImage.snp.trailing).offset(8)
            make.width.equalTo(17)
            make.height.equalTo(17)
        }
        
        daySummaryContentView.addSubviews(sunriseTimeLabel, sunsetTimeLabel)
        
        sunriseTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sunriseImage.snp.bottom).offset(5)
            make.centerX.equalTo(sunriseImage.snp.centerX)
        }
        
        sunsetTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sunsetImage.snp.bottom).offset(5)
            make.centerX.equalTo(sunsetImage.snp.centerX)
        }
        
    }
    
}
