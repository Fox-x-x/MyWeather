//
//  BriefWeatherInfoTableViewCell.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 31.05.2021.
//

import UIKit

class BriefWeatherInfoTableViewCell: UITableViewCell {
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    var dayCached: DayCached? {
        didSet {
            guard let dayCached = dayCached else { return }
            
//            print("dayCached...")
            
            dateLabel.text = dateToString(dayCached.dt, withFormat: "dd") + "/" + dateToString(dayCached.dt, withFormat: "MM")
            
//            if let weatherID = dayCached.weather.first?.id {
//                let imageName = getImageByWeatherID(id: weatherID)
//                rainyCloudImage.image = UIImage(named: imageName)
//            }
            
            downfallPossibilityLabel.text = String(format: "%.0f", floor(dayCached.pop * 100)) + "%"
            downfallDescriptionLabel.text = dayCached.weather.first?.weatherDescription
            
            if let minTemp = dayCached.temp.min, let maxTemp = dayCached.temp.max {
                temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(minTemp, to: options.temperature))) + "-" + String(format: "%.0f", floor(convertTemperature(maxTemp, to: options.temperature))) + "°  >"
            }
            
            
        }
    }
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            
//            print("day...")
            
            dateLabel.text = dateToString(day.dt, withFormat: "dd") + "/" + dateToString(day.dt, withFormat: "MM")
            
//            if let weatherID = day.weather.first?.id {
//                let imageName = getImageByWeatherID(id: weatherID)
//                rainyCloudImage.image = UIImage(named: imageName)
//            }
            
            downfallPossibilityLabel.text = String(format: "%.0f", floor(day.pop * 100)) + "%"
            downfallDescriptionLabel.text = day.weather.first?.weatherDescription
            
            temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(day.temp.min, to: options.temperature))) + "-" + String(format: "%.0f", floor(convertTemperature(day.temp.max, to: options.temperature))) + "°  >"
            
        }
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E9EEFA")
        return view
    }()
    
    private lazy var leftsideView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var rightsideView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var downfallDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "--"
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#9A9696")
        label.numberOfLines = 1
        label.text = "--/--"
        return label
    }()
    
    private lazy var rainyCloudImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rainy-cloud")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var downfallPossibilityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(hex: "#204EC7")
        label.numberOfLines = 1
        label.text = "--"
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#000000")
        label.numberOfLines = 1
        label.text = "--"
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
            make.centerY.equalToSuperview()
        }
        
        containerView.addSubviews(leftsideView, rightsideView, downfallDescriptionLabel)
        
        // MARK: - leftside view
        leftsideView.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.width.equalToSuperview().multipliedBy(0.17)
            make.leading.equalToSuperview()
        }
        
        leftsideView.addSubviews(dateLabel, rainyCloudImage, downfallPossibilityLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
        }
        
        rainyCloudImage.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4.5)
            make.leading.equalTo(dateLabel)
            make.width.equalTo(15)
            make.height.equalTo(17)
        }
        
        downfallPossibilityLabel.snp.makeConstraints { make in
            make.leading.equalTo(rainyCloudImage.snp.trailing).offset(5)
            make.centerY.equalTo(rainyCloudImage.snp.centerY)
        }
        
        // MARK: - rightside view
        rightsideView.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.width.equalToSuperview().multipliedBy(0.23)
            make.trailing.equalToSuperview()
        }
        
        rightsideView.addSubview(temperatureLabel)
        
        temperatureLabel.snp.makeConstraints { make in
            make.leading.equalTo(downfallDescriptionLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        // MARK: - center view
        downfallDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(leftsideView.snp.trailing).offset(5)
            make.trailing.equalTo(rightsideView.snp.leading).offset(-5)
            make.centerY.equalToSuperview()
        }
        
    }

}
