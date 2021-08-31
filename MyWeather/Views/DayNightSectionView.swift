//
//  DayNightSectionView.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 06.08.2021.
//

import Foundation
import UIKit
import SnapKit

final class DayNightSectionView: UIView {
    
    var conditionName: String? {
        didSet {
            guard let conditionName = conditionName else { return }
            weatherLabel.text = conditionName
        }
    }
    
    var imageName: String? {
        didSet {
            guard let imageName = imageName else { return }
            weatherImage.image = UIImage(named: imageName)
        }
    }
    
    var value: String? {
        didSet {
            guard let value = value else { return }
            weatherValueLabel.text = value
        }
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var weatherImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var weatherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    private lazy var weatherValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var feelsLikeSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1)
        return view
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
        
        contentView.addSubview(weatherImage)
        
        weatherImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(24)
            make.height.equalTo(26)
        }
        
        contentView.addSubview(weatherLabel)
        
        weatherLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherImage.snp.centerY)
            make.leading.equalTo(weatherImage.snp.trailing).offset(18)
        }
        
        contentView.addSubview(weatherValueLabel)
        
        weatherValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherImage.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(feelsLikeSeparatorView)
        
        feelsLikeSeparatorView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
    }
    
}
