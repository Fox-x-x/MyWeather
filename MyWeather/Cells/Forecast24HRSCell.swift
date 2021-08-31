//
//  Forecast24HRSCell.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 30.05.2021.
//

import UIKit
import SnapKit
import Hex

final class Forecast24HRSCell: UICollectionViewCell {
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    var hourCached: HourCached? {
        didSet {
            guard let hourCached = hourCached else { return }
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h a"
            }
            timeLabel.text = dateToString(Double(hourCached.dt), withFormat: timeFormat)
            
            temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(hourCached.temp, to: options.temperature))) + "°"
            
//            print("hourCached...")
            
            if let weatherID = hourCached.weather.first?.id {
                let imageName = getImageByWeatherID(id: weatherID)
                cloudyImage.image = UIImage(named: imageName)
            }
            
        }
    }
    
    var hour: Hour? {
        didSet {
            guard let hour = hour else { return }
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h a"
            }
            timeLabel.text = dateToString(Double(hour.dt), withFormat: timeFormat)
            
            temperatureLabel.text = String(format: "%.0f", floor(convertTemperature(hour.temp, to: options.temperature))) + "°"
            
//            print("hour...")
            
            if let weatherID = hour.weather.first?.id {
                let imageName = getImageByWeatherID(id: weatherID)
                cloudyImage.image = UIImage(named: imageName)
            }
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(hex: "#ABBCEA").cgColor
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "--:--"
        label.textColor = UIColor(hex: "#9C9797")
        return label
    }()
    
    private lazy var cloudyImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "--°"
        label.textColor = UIColor(hex: "#343030")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubviews(timeLabel, cloudyImage, temperatureLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        cloudyImage.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-7)
            make.centerX.equalToSuperview()
        }
    }
    
}
