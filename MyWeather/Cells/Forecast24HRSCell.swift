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
        label.text = "12:00"
        label.textColor = UIColor(hex: "#9C9797")
        return label
    }()
    
    private lazy var cloudyImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "sunny")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "25°"
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
            make.top.leading.trailing.bottom.equalToSuperview()
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
