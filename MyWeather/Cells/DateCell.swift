//
//  DateCell.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 05.08.2021.
//

import UIKit

class DateCell: UICollectionViewCell {
    
    var textColor: UIColor? {
        didSet {
            guard let textColor = textColor else { return }
            dateLabel.textColor = textColor
        }
    }
    
    var dayCached: DayCached? {
        didSet {
            guard let dayCached = dayCached else { return }
            dateLabel.text = dateToString(dayCached.dt, withFormat: "dd") + "/" + dateToString(dayCached.dt, withFormat: "MM") + dateToString(dayCached.dt, withFormat: " E")
        }
    }
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            dateLabel.text = dateToString(day.dt, withFormat: "dd") + "/" + dateToString(day.dt, withFormat: "MM") + dateToString(day.dt, withFormat: " E")
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "--"
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
        
        containerView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
        }
        
    }
    
}
