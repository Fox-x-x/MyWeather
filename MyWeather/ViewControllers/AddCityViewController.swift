//
//  ViewController2.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit
import CoreData

protocol AddCityManagerDelegate {
    func didAddCity(city: CityWeather)
}

class AddCityViewController: UIViewController {
    
    var delegate: AddCityManagerDelegate?
    var cityManager = NetworkManager()
    
    private var coreDataManager: CoreDataStack
    
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
    
    init(coreDataManager: CoreDataStack) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        cityManager.cityLocationDelegate = self
        
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
        
        let alert = UIAlertController(title: "???????????????? ??????????", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "????????????????", style: .default) { [weak self] action in
            
            guard let vc = self else { return }
            
            if let cityName = alert.textFields?.first?.text {
                vc.cityManager.fetchCityLocation(cityName: cityName)
                
                print(cityName)
            }
        }
        
        let cancel = UIAlertAction(title: "????????????", style: .cancel, handler: nil)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "?????????????? ???????????????? ????????????"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }

}

extension AddCityViewController: FindCityLocationManagerDelegate {
    
    func didReceiveCityData(_ cityLocationManager: NetworkManager, cityData: City) {
        if let geoObject = cityData.response.geoObjectCollection.featureMember.first?.geoObject {
            
            // ?????????????????? ?? ????
            let context = coreDataManager.context
            let cityLocationData = coreDataManager.createObject(from: CityWeather.self, with: context)
            
            cityLocationData.cityName = geoObject.city
            cityLocationData.countryName = geoObject.country
            cityLocationData.lat = geoObject.lat
            cityLocationData.lon = geoObject.lon

            coreDataManager.save(context: context)
            
            // ???????????????????? ??????????????????????, ?????? ?????????? ???????????? ?? ????????????????
            DispatchQueue.main.async {
                self.delegate?.didAddCity(city: cityLocationData)
                print("cityName = \(geoObject.city)")
            }
        } else {
            // ????????????: ?????????? ???? ????????????
            print("????????????: ?????????? ???? ????????????")
            DispatchQueue.main.async {
                handleApiError(error: .cityNotFound, vc: self)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            handleApiError(error: .networkError, vc: self)
        }
    }
    
}
