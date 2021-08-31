//
//  SunAndMoonView.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 11.08.2021.
//

import Foundation
import UIKit

final class SunAndMoonView: UIView {
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    var timeZoneOffset: Double = 0
    
    // MARK: - Set valuees
    
    var dayCached: DayCached? {
        didSet {
            guard let dayCached = dayCached else { return }
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h:mm a"
            }
            sunriseTimeLabel.text = dateToString(dayCached.sunrise + timeZoneOffset, withFormat: timeFormat)
            sunsetTimeLabel.text = dateToString(dayCached.sunset + timeZoneOffset, withFormat: timeFormat)
            
            moonriseTimeLabel.text = dateToString(dayCached.moonrise + timeZoneOffset, withFormat: timeFormat)
            moonsetTimeLabel.text = dateToString(dayCached.moonset + timeZoneOffset, withFormat: timeFormat)
            
        }
    }
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h:mm a"
            }
            sunriseTimeLabel.text = dateToString(day.sunrise + timeZoneOffset, withFormat: timeFormat)
            sunsetTimeLabel.text = dateToString(day.sunset + timeZoneOffset, withFormat: timeFormat)
            
            moonriseTimeLabel.text = dateToString(day.moonrise + timeZoneOffset, withFormat: timeFormat)
            moonsetTimeLabel.text = dateToString(day.moonset + timeZoneOffset, withFormat: timeFormat)
            
        }
    }
    
    // MARK: - UI
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var sunAndMoonLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "Солнце и луна"
        return label
    }()
    
    private lazy var sunImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "sunny")
        return iv
    }()
    
    private lazy var sunriseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#9A9696")
        label.numberOfLines = 1
        label.text = "Восход"
        return label
    }()
    
    private lazy var sunriseTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "05:19"
        return label
    }()
    
    private lazy var sunsetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#9A9696")
        label.numberOfLines = 1
        label.text = "Заход"
        return label
    }()
    
    private lazy var sunsetTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "19:46"
        return label
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1)
        return view
    }()
    
    private lazy var moonImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "moon")
        return iv
    }()
    
    private lazy var moonriseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#9A9696")
        label.numberOfLines = 1
        label.text = "Восход"
        return label
    }()
    
    private lazy var moonriseTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "05:19"
        return label
    }()
    
    private lazy var moonsetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#9A9696")
        label.numberOfLines = 1
        label.text = "Заход"
        return label
    }()
    
    private lazy var moonsetTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "19:46"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Draw dashed lines
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // рисуем пунктирные линии
        let color = UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1)
        
        let leftLineStartPoint1 = CGPoint(x: 0, y: 93)
        let leftLineEndPoint1 = CGPoint(x: self.frame.width / 2 - 16, y: 93)
        createDashedLine(from: leftLineStartPoint1, to: leftLineEndPoint1, color: color, strokeLength: 4, gapLength: 3, width: 0.5)
        
        let leftLineStartPoint2 = CGPoint(x: 0, y: 129)
        let leftLineEndPoint2 = CGPoint(x: self.frame.width / 2 - 16, y: 129)
        createDashedLine(from: leftLineStartPoint2, to: leftLineEndPoint2, color: color, strokeLength: 4, gapLength: 3, width: 0.5)
        
        let rightLineStartPoint1 = CGPoint(x: self.frame.width / 2 + 16, y: 93)
        let rightLineEndPoint1 = CGPoint(x: self.frame.width, y: 93)
        createDashedLine(from: rightLineStartPoint1, to: rightLineEndPoint1, color: color, strokeLength: 4, gapLength: 3, width: 0.5)
        
        let rightLineStartPoint2 = CGPoint(x: self.frame.width / 2 + 16, y: 129)
        let rightLineEndPoint2 = CGPoint(x: self.frame.width, y: 129)
        createDashedLine(from: rightLineStartPoint2, to: rightLineEndPoint2, color: color, strokeLength: 4, gapLength: 3, width: 0.5)
        
    }
    
    // MARK: - Layout
    private func setupLayout() {
        
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(sunAndMoonLabel)
        
        sunAndMoonLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        // left side
        contentView.addSubview(sunImage)
        
        sunImage.snp.makeConstraints { make in
            make.top.equalTo(sunAndMoonLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(sunriseLabel)
        
        sunriseLabel.snp.makeConstraints { make in
            make.top.equalTo(sunImage.snp.bottom).offset(20)
            make.leading.equalTo(sunImage.snp.leading)
        }
        
        contentView.addSubview(sunriseTimeLabel)
        
        sunriseTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sunriseLabel.snp.top)
            make.trailing.equalTo(self.snp.centerX).offset(-16)
        }
        
        contentView.addSubview(sunsetLabel)
        
        sunsetLabel.snp.makeConstraints { make in
            make.top.equalTo(sunriseLabel.snp.bottom).offset(17)
            make.leading.equalTo(sunImage.snp.leading)
        }
        
        contentView.addSubview(sunsetTimeLabel)
        
        sunsetTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sunriseTimeLabel.snp.bottom).offset(17)
            make.trailing.equalTo(self.snp.centerX).offset(-16)
        }
        
        contentView.addSubview(separator)
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(sunAndMoonLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(0.5)
            make.height.equalTo(100)
        }
        
        // right side
        contentView.addSubview(moonImage)
        
        moonImage.snp.makeConstraints { make in
            make.top.equalTo(sunImage.snp.top)
            make.leading.equalTo(separator.snp.trailing).offset(28)
            make.width.equalTo(18)
            make.height.equalTo(16)
        }
        
        contentView.addSubview(moonriseLabel)
        
        moonriseLabel.snp.makeConstraints { make in
            make.top.equalTo(sunriseLabel.snp.top)
            make.leading.equalTo(moonImage.snp.leading)
        }
        
        contentView.addSubview(moonriseTimeLabel)
        
        moonriseTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sunriseTimeLabel)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        contentView.addSubview(moonsetLabel)
        
        moonsetLabel.snp.makeConstraints { make in
            make.top.equalTo(sunsetLabel.snp.top)
            make.leading.equalTo(moonImage.snp.leading)
        }
        
        contentView.addSubview(moonsetTimeLabel)
        
        moonsetTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sunsetTimeLabel)
            make.trailing.equalTo(moonriseTimeLabel.snp.trailing)
        }
        
    }
    
}
