//
//  SettingsViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 22.05.2021.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    // MARK: - UI Elements: background
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var cloudImage1: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "cloud-1")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.3
        return iv
    }()
    
    private lazy var cloudImage2: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "cloud-2")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.9
        return iv
    }()
    
    private lazy var cloudImage3: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "cloud-3")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.9
        return iv
    }()
    
    // MARK: - UI Elements: settings
    
    private lazy var settingsView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var settingsContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var settingsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Настройки"
        label.textColor = UIColor(hex: "#272722")
        return label
    }()
    
    private lazy var optionsNamesStackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    private lazy var optionsValuesStackView: UIStackView = {
        let sv = UIStackView()
        return sv
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Установить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel").alpha(0.8), for: .highlighted)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel").alpha(0.8), for: .selected)
        button.setBackgroundImage(#imageLiteral(resourceName: "orange-pixel").alpha(0.5), for: .disabled)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
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
        
        view.addSubview(backgroundView)
        backgroundView.addSubviews(cloudImage1, cloudImage2, cloudImage3)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cloudImage1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(37)
            make.leading.equalToSuperview()
            make.width.equalTo(246)
            make.height.equalTo(58)
        }
        
        cloudImage2.snp.makeConstraints { make in
            make.top.equalTo(cloudImage1.snp.bottom).offset(26)
            make.trailing.equalToSuperview()
            make.width.equalTo(182)
            make.height.equalTo(94)
        }
        
        cloudImage3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-95)
            make.width.equalTo(216)
            make.height.equalTo(65)
        }
        
        backgroundView.addSubview(settingsView)
        
        settingsView.backgroundColor = UIColor(hex: "#E9EEFA")
        
        settingsView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
        }
        
        settingsView.addSubview(settingsContentView)
        
        settingsContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(27)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(280)
        }
        
        settingsContentView.addSubview(settingsTitleLabel)
        
        settingsTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        let options = OptionsStorage.options
        
        for option in options {
            
            let optionLabel = UILabel()
            optionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            optionLabel.text = option.title
            optionLabel.textColor = UIColor(hex: "#898383")
            
            optionsNamesStackView.addArrangedSubview(optionLabel)
            
            let items = option.values
            let optionControl = UISegmentedControl(items: items)
            optionControl.backgroundColor = UIColor(hex: "#FEEDE9")
            optionControl.selectedSegmentTintColor = UIColor(hex: "#1F4DC5")
            optionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
            
            optionsValuesStackView.addArrangedSubview(optionControl)
            
        }
        
        optionsNamesStackView.axis = .vertical
        optionsNamesStackView.distribution = .fillEqually
        optionsNamesStackView.spacing = 30
        
        optionsValuesStackView.axis = .vertical
        optionsValuesStackView.distribution = .equalCentering
        optionsValuesStackView.spacing = 20
        
        settingsContentView.addSubview(optionsNamesStackView)
        
        optionsNamesStackView.snp.makeConstraints { make in
            make.top.equalTo(settingsTitleLabel.snp.bottom).offset(24)
            make.leading.equalTo(settingsTitleLabel.snp.leading)
        }
        
        settingsContentView.addSubview(optionsValuesStackView)

        optionsValuesStackView.snp.makeConstraints { make in
            make.top.equalTo(settingsTitleLabel.snp.bottom).offset(15)
            make.trailing.equalToSuperview()
        }
        
        settingsContentView.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(optionsValuesStackView.snp.bottom).offset(37)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-16)
        }
        
    }
    
    // MARK: - Functions
    
    @objc private func saveButtonPressed() {
        print("saved")
        coordinator?.navigationController.popToRootViewController(animated: true)
    }

}
