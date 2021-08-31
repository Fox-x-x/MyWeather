//
//  NavigationView.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 04.08.2021.
//

import Foundation
import SnapKit

final class NavigationView: UIView {
    
    var title: String? {
        didSet {
            guard let title = title else { return }
            titleLabel.text = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: "#9A9696")
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var arrowLeftImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "arrow.left")
        iv.tintColor = UIColor(hex: "#000000")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        
        backgroundColor = .white
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(33)
        }
        
        addSubview(arrowLeftImage)
        
        arrowLeftImage.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(15)
        }
        
    }
    
}


