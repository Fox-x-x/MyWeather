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
    
//    private let notificationCenter = NotificationCenter.default
    private var coreDataManager: CoreDataStack
//    private var context: NSManagedObjectContext?
//    private lazy var backgroundContext = coreDataManager.backgroundContext
    
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
//        print("pressed")
        
        let alert = UIAlertController(title: "Добавить город", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Добавить", style: .default) { [weak self] action in
            
            guard let vc = self else { return }
            
            if let cityName = alert.textFields?.first?.text {
                vc.cityManager.fetchCityLocation(cityName: cityName)
                // делаем запрос в сеть на поиск города. Если находим, создаем объект City, добавляем в БД вместе с его Weather (будет пустой)
                // отправляем нотификацию в MainScreenViewController, там в didAddCity берем этот объект и
                // кладем в CityWeatherViewController. Тот если найдет в БД weatherData для этого City, подгрузит сначала ее, если нет, то сразу из сети
                
                print(cityName)
            }
            
//            if let dir = vc.currentDir, let name = alert.textFields?.first?.text {
//                var newDir = dir
//                newDir.appendPathComponent(name)
//                do {
//                    try vc.fileManager.createDirectory(at: newDir, withIntermediateDirectories: false, attributes: nil)
//                    vc.showFilesFor(dir: dir, using: vc.fileManager)
//                } catch {
//                    print("\(error.localizedDescription)")
//                }
//            }
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "введите название города"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }

}

extension AddCityViewController: FindCityLocationManagerDelegate {
    
    func didReceiveCityData(_ cityLocationManager: NetworkManager, cityData: City) {
        if let geoObject = cityData.response.geoObjectCollection.featureMember.first?.geoObject {
            
            // добавляем в БД
            let context = coreDataManager.context
            let cityLocationData = coreDataManager.createObject(from: CityWeather.self, with: context)
            
            cityLocationData.cityName = geoObject.city
            cityLocationData.countryName = geoObject.country
            cityLocationData.lat = geoObject.lat
            cityLocationData.lon = geoObject.lon

            coreDataManager.save(context: context)
            
            // отправляем нотификацию, что город найден и добавлен
            DispatchQueue.main.async {
                self.delegate?.didAddCity(city: cityLocationData)
                print("cityName = \(geoObject.city)")
            }
        } else {
            // ошибка: город не найден
            print("Ошибка: город не найден")
            handleApiError(error: .cityNotFound, vc: self)
        }
    }
    
    func didFailWithError(error: Error) {
        handleApiError(error: .networkError, vc: self)
    }
    
}
