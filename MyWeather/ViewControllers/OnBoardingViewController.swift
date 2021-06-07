//
//  ViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 17.05.2021.
//

import UIKit
import Hex
import SnapKit

class OnBoardingViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var mainImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "girl")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var mainTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(hex: "#F8F5F5")
        label.numberOfLines = 0
        label.text = "Разрешить приложению Weather использовать данные о местоположении вашего устройства"
        return label
    }()
    
    private lazy var firstAdditionalTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#FFFFFF")
        label.numberOfLines = 0
        label.text = "Чтобы получить более точные прогнозы погоды во время движения или путешествия"
        return label
    }()
    
    private lazy var secondAdditionalTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: "#FFFFFF")
        label.numberOfLines = 0
        label.text = "Вы можете изменить свой выбор в любое время из меню приложения"
        return label
    }()
    
    private lazy var useLocationButton: UIButton = {
        let button = UIButton()
        button.setTitle("ИСПОЛЬЗОВАТЬ МЕСТОПОЛОЖЕНИЕ УСТРОЙСТВА", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel").alpha(0.8), for: .highlighted)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel").alpha(0.8), for: .selected)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel").alpha(0.5), for: .disabled)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(useLocationButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var addLocationsManuallyButton: UIButton = {
        let button = UIButton()
        button.setTitle("НЕТ, Я БУДУ ДОБАВЛЯТЬ ЛОКАЦИИ", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addLocationsManuallyButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        setupLayout()
        
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        
        view.backgroundColor = UIColor(hex: "#1F4DC5")
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(mainImage, mainTextLabel, firstAdditionalTextLabel, secondAdditionalTextLabel, useLocationButton, addLocationsManuallyButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.top.bottom.equalToSuperview()
        }

        mainImage.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(62)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-17)
            make.height.equalTo(334)
        }

        mainTextLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(19)
            make.trailing.equalToSuperview().offset(-19)
        }

        firstAdditionalTextLabel.snp.makeConstraints { make in
            make.top.equalTo(mainTextLabel.snp.bottom).offset(30)
            make.leading.equalTo(mainTextLabel.snp.leading)
            make.trailing.equalTo(mainTextLabel.snp.trailing)
        }

        secondAdditionalTextLabel.snp.makeConstraints { make in
            make.top.equalTo(firstAdditionalTextLabel.snp.bottom).offset(10)
            make.leading.equalTo(mainTextLabel.snp.leading)
            make.trailing.equalTo(mainTextLabel.snp.trailing)
        }

        useLocationButton.snp.makeConstraints { make in
            make.top.equalTo(secondAdditionalTextLabel.snp.bottom).offset(40)
            make.leading.equalTo(mainTextLabel.snp.leading)
            make.trailing.equalTo(mainTextLabel.snp.trailing)
            make.height.equalTo(40)
        }

        addLocationsManuallyButton.snp.makeConstraints { make in
            make.top.equalTo(useLocationButton.snp.bottom).offset(40)
            make.leading.equalTo(mainTextLabel.snp.leading)
            make.trailing.equalTo(mainTextLabel.snp.trailing)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-50)
        }
        
    }
    
    @objc private func useLocationButtonPressed() {
        print("use location pressed!")
        coordinator?.navigationController.popToRootViewController(animated: true)
    }
    
    @objc private func addLocationsManuallyButtonPressed() {
        print("add location pressed!")
        coordinator?.navigationController.popToRootViewController(animated: true)
    }

}

// MARK: - Extensions

extension OnBoardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
    }
}

