//
//  HourCell.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 15.08.2021.
//

import UIKit
import Hex

class HourCell: UICollectionViewCell {
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    var hourCached: HourCached? {
        didSet {
            guard let hourCached = hourCached else { return }
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h:mm a"
            }
            timeLabel.text = dateToString(Double(hourCached.dt), withFormat: timeFormat)
            dateLabel.text = dateToString(Double(hourCached.dt), withFormat: "E dd / MM")
            
            temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(hourCached.temp, to: options.temperature))) + "°"
            weatherDescriptionLabel.text = hourCached.weather.first?.weatherDescription
            windValueLabel.text = String(format: "%.0f", floor(convertWindSpeed(hourCached.windSpeed, to: options.winSpeed))) + " м/с"
            
            downfallValueLabel.text = String(format: "%.0f", floor(hourCached.pop * 100)) + "%"
            
            cloudsValueLabel.text = String(hourCached.clouds) + "%"
            
        }
    }
    
    var hour: Hour? {
        didSet {
            guard let hour = hour else { return }
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h:mm a"
            }
            timeLabel.text = dateToString(Double(hour.dt), withFormat: timeFormat)
            dateLabel.text = dateToString(Double(hour.dt), withFormat: "E dd/MM")
            
            temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(hour.temp, to: options.temperature))) + "°"
            weatherDescriptionLabel.text = hour.weather.first?.weatherDescription
            windValueLabel.text = String(format: "%.0f", floor(convertWindSpeed(hour.windSpeed, to: options.winSpeed))) + " м/с"
            
            downfallValueLabel.text = String(format: "%.0f", floor(hour.pop * 100)) + "%"
            
            cloudsValueLabel.text = String(hour.clouds) + "%"
            
        }
    }
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "--"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "--:--"
        label.textColor = UIColor(hex: "#9A9696")
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "--"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var moonImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "moon")
        return iv
    }()
    
    private lazy var weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "--"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var windImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "wind")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var windLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "Ветер"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var windValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "--"
        label.textColor = UIColor(hex: "#9A9696")
        return label
    }()
    
    private lazy var rainDropsImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rain-drops")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var downfallLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "Атмосферные осадки"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var downfallValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "--"
        label.textColor = UIColor(hex: "#9A9696")
        return label
    }()
    
    private lazy var cloudsImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "cloudy-blue")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var cloudsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "Облачность"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var cloudsValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "--"
        label.textColor = UIColor(hex: "#9A9696")
        return label
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        backgroundColor = UIColor(hex: "#E9EEFA")
        
        contentView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(temperatureLabel)
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.centerX.equalTo(timeLabel.snp.centerX)
        }
        
        contentView.addSubview(moonImage)
        
        moonImage.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.leading.equalTo(timeLabel.snp.trailing).offset(16)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        
        contentView.addSubview(weatherDescriptionLabel)
        
        weatherDescriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(moonImage.snp.centerY)
            make.leading.equalTo(moonImage.snp.trailing).offset(4)
        }
        
        contentView.addSubview(windImage)
        
        windImage.snp.makeConstraints { make in
            make.top.equalTo(moonImage.snp.bottom).offset(16)
            make.leading.equalTo(moonImage)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        contentView.addSubview(windLabel)
        
        windLabel.snp.makeConstraints { make in
            make.centerY.equalTo(windImage.snp.centerY)
            make.leading.equalTo(windImage.snp.trailing).offset(4)
        }
        
        contentView.addSubview(windValueLabel)
        
        windValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(windLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(rainDropsImage)
        
        rainDropsImage.snp.makeConstraints { make in
            make.top.equalTo(windImage.snp.bottom).offset(16)
            make.leading.equalTo(moonImage)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        
        contentView.addSubview(downfallLabel)
        
        downfallLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rainDropsImage.snp.centerY)
            make.leading.equalTo(rainDropsImage.snp.trailing).offset(4)
        }
        
        contentView.addSubview(downfallValueLabel)
        
        downfallValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(downfallLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(cloudsImage)
        
        cloudsImage.snp.makeConstraints { make in
            make.top.equalTo(rainDropsImage.snp.bottom).offset(16)
            make.leading.equalTo(moonImage)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        
        contentView.addSubview(cloudsLabel)
        
        cloudsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(cloudsImage.snp.centerY)
            make.leading.equalTo(cloudsImage.snp.trailing).offset(4)
        }
        
        contentView.addSubview(cloudsValueLabel)
        
        cloudsValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(cloudsLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(separator)
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(cloudsValueLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
    }
    
}
