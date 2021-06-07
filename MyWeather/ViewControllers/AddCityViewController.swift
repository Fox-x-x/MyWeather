//
//  ViewController2.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit

class AddCityViewController: UIViewController {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var addCityButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addCityButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
//        title = "Kenig, Russia"
        
        setupLayout()
        
    }
    
    private func setupLayout() {
        
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.addSubview(addCityButton)
        
        addCityButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
    }
    
    @objc private func addCityButtonPressed() {
        print("pressed")
//        NetworkManager.getWeather()
    }

}
