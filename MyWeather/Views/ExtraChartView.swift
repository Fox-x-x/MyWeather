//
//  ChartView.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 17.08.2021.
//

import UIKit

final class ExtraChartView: UIView {
    
    let daysNumber = 7

    var hoursCached: [HourCached]? {
        didSet {
            guard let hoursCached = hoursCached else { return }
            
            let trimmedHoursCached = hoursCached.prefix(daysNumber)
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h a"
            }
            
            for (index, _) in rainLabels.enumerated() {
                rainLabels[index].text = String(format: "%.0f", floor(trimmedHoursCached[index].pop * 100)) + "%"
                timeLabels[index].text = dateToString(Double(trimmedHoursCached[index].dt), withFormat: timeFormat)
            }
        }
    }

    var hours: [Hour]? {
        didSet {
            guard let hours = hours else { return }
            
            let trimmedHours = hours.prefix(daysNumber)
            
            var timeFormat = "HH:mm"
            if options.timeFormat == .hours12 {
                timeFormat = "h a"
            }
            
            for (index, _) in rainLabels.enumerated() {
                rainLabels[index].text = String(format: "%.0f", floor(trimmedHours[index].pop * 100)) + "%"
                timeLabels[index].text = dateToString(Double(trimmedHours[index].dt), withFormat: timeFormat)
            }
        }
    }
    
    var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    private lazy var rainLabels: [UILabel] = {
        var array = [UILabel]()
        
        for _ in 1...daysNumber {
            let rainLabel = UILabel()
            rainLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            rainLabel.textColor = UIColor(hex: "#272722")
            rainLabel.text = "--"
            array.append(rainLabel)
        }
        
        return array
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.914, green: 0.933, blue: 0.98, alpha: 1)
        return view
    }()
    
    private lazy var cloudyImagesStackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    private lazy var rainLabelsStackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    private lazy var blueBlocksStackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    private lazy var timeLabelsStackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    private lazy var timelineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1)
        return view
    }()
    
    private lazy var blueBlocks: [UIImageView] = {
        var array = [UIImageView]()
        
        for _ in 1...daysNumber {
            
            let blockImage: UIImageView = {
                let iv = UIImageView()
                iv.image = UIImage(named: "blue-block")
                iv.contentMode = .scaleAspectFit
                return iv
            }()
            
            array.append(blockImage)
        }
        
        return array
    }()
    
    private lazy var timeLabels: [UILabel] = {
        var array = [UILabel]()
        
        for _ in 1...daysNumber {
            let timeLabel = UILabel()
            timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            timeLabel.textColor = UIColor(hex: "#272722")
            timeLabel.text = "--"
            array.append(timeLabel)
        }
        
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let numberOfDays = 7
        
        for _ in 1...numberOfDays {
            
            let cloudyImage: UIImageView = {
                let iv = UIImageView()
                iv.image = UIImage(named: "rainy-cloud")
                iv.contentMode = .scaleAspectFit
                return iv
            }()
            
            cloudyImagesStackView.addArrangedSubview(cloudyImage)
            
        }
        
        cloudyImagesStackView.axis = .horizontal
        cloudyImagesStackView.distribution = .equalSpacing
        
        contentView.addSubview(cloudyImagesStackView)
        
        cloudyImagesStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
        
        for label in rainLabels {
            rainLabelsStackView.addArrangedSubview(label)
        }
        
        rainLabelsStackView.axis = .horizontal
        rainLabelsStackView.distribution = .equalSpacing
        
        contentView.addSubview(rainLabelsStackView)
        
        rainLabelsStackView.snp.makeConstraints { make in
            make.top.equalTo(cloudyImagesStackView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
        contentView.addSubview(timelineView)
        
        timelineView.snp.makeConstraints { make in
            make.top.equalTo(rainLabelsStackView.snp.bottom).offset(13)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        
        for block in blueBlocks {
            blueBlocksStackView.addArrangedSubview(block)
        }
        
        blueBlocksStackView.axis = .horizontal
        blueBlocksStackView.distribution = .equalSpacing
        
        contentView.addSubview(blueBlocksStackView)
        
        blueBlocksStackView.snp.makeConstraints { make in
            make.centerY.equalTo(timelineView.snp.centerY)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(8)
        }
        
        for label in timeLabels {
            timeLabelsStackView.addArrangedSubview(label)
        }
        
        timeLabelsStackView.axis = .horizontal
        timeLabelsStackView.distribution = .equalSpacing
        
        contentView.addSubview(timeLabelsStackView)
        
        timeLabelsStackView.snp.makeConstraints { make in
            make.top.equalTo(timelineView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview()
            make.height.equalTo(16)
        }
        
    }

}
