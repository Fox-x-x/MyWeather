//
//  DailyViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 02.08.2021.
//

import UIKit
import SnapKit
import Hex
import CoreLocation

class DailyWeatherViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var city: CityWeather
    
    private var weatherManager = NetworkManager()
    
    private var dayNumber: IndexPath
    
    private var daysCached = [DayCached]()
    private var days = [Day]()
    
    private var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    private let coreDataManager = CoreDataStack()
    private lazy var context = coreDataManager.context
    
    private var locationManager: CLLocationManager?
    
    private var isInCacheMode = false
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var navigationView: NavigationView = {
        let view = NavigationView()
        return view
    }()
    
    private lazy var cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "New York"
        return label
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .medium
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private lazy var navigationViewTap = UITapGestureRecognizer(target: self, action: #selector(navigationViewTapped))
    
    private lazy var daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            DateCell.self,
            forCellWithReuseIdentifier: String(describing: DateCell.self)
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var dayView: DayNightView = {
        let view = DayNightView()
        view.dayTimeName = "День"
        return view
    }()
    
    private lazy var nightView: DayNightView = {
        let view = DayNightView()
        view.dayTimeName = "Ночь"
        return view
    }()
    
    private lazy var sunAndMoonView = SunAndMoonView()
    
    // MARK: - Init
    
    init(city: CityWeather, dayNumber: IndexPath) {
        self.city = city
        self.dayNumber = dayNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGreen
        navigationView.title = "Дневная погода"
        weatherManager.weatherDataDelegate = self
        cityNameLabel.text = city.cityName
        navigationView.addGestureRecognizer(navigationViewTap)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        
        options = loadSettings()
        setupLayout()
        updateUI()
        
    }
    
    private func updateUI() {
        
        dayView.options = options
        nightView.options = options
        sunAndMoonView.options = options
        
        if let weatherFromDB = city.weather {
            let weatherDecoder = WeatherDecoder()
            let weather = weatherDecoder.fromDataBase(weatherFromDB: weatherFromDB, coreDataManager: coreDataManager)
            
            nightView.isInNightMode = true
            
            DispatchQueue.main.async {
                self.isInCacheMode = true
                
                self.daysCached = self.getDaysFromWeather(from: weather)
                self.dayView.dayCached = self.daysCached[self.dayNumber.item]
                self.nightView.dayCached = self.daysCached[self.dayNumber.item]
                self.sunAndMoonView.dayCached = self.daysCached[self.dayNumber.item]
                self.sunAndMoonView.timeZoneOffset = weatherFromDB.timezoneOffset
                
                self.daysCollectionView.reloadData()
                self.daysCollectionView.selectItem(at: self.dayNumber, animated: true, scrollPosition: .left)
            }
            
            let backgroundQueue = DispatchQueue.global(qos: .background)
            backgroundQueue.async {
                if self.city.geolocated == true {
                    self.locationManager?.startUpdatingLocation()
                } else {
                    self.weatherManager.fetchWeather(for: self.city)
                }
            }
            
        } else {
            if self.city.geolocated == true {
                self.locationManager?.startUpdatingLocation()
            } else {
                self.weatherManager.fetchWeather(for: self.city)
            }
        }
        
    }
    
    @objc private func navigationViewTapped() {
        coordinator?.goBack()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(navigationView)
        
        navigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(cityNameLabel)
        
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(spinner)
        
        spinner.snp.makeConstraints { make in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        contentView.addSubview(daysCollectionView)
        
        daysCollectionView.snp.makeConstraints { make in
            make.top.equalTo(spinner.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        contentView.addSubview(dayView)
        
        dayView.snp.makeConstraints { make in
            make.top.equalTo(daysCollectionView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(340)
        }
        
        contentView.addSubview(nightView)
        
        nightView.snp.makeConstraints { make in
            make.top.equalTo(dayView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(340)
        }
        
        contentView.addSubview(sunAndMoonView)
        
        sunAndMoonView.snp.makeConstraints { make in
            make.top.equalTo(nightView.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(190)
            make.bottom.equalToSuperview().offset(-16)
        }
        
    }
}

// MARK: - CollectionView extension

extension DailyWeatherViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInCacheMode {
            return daysCached.count
        } else {
            return days.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as! DateCell
        
        if isInCacheMode {
            cell.dayCached = daysCached[indexPath.item]
            if indexPath.item == dayNumber.item {
                cell.containerView.backgroundColor = UIColor(hex: "#204EC7")
                cell.textColor = UIColor(hex: "#FFFFFF")
            } else {
                cell.containerView.backgroundColor = .white
                cell.textColor = UIColor(hex: "#272722")
            }
        } else {
            cell.day = days[indexPath.item]
            if indexPath.item == dayNumber.item {
                cell.containerView.backgroundColor = UIColor(hex: "#204EC7")
                cell.textColor = UIColor(hex: "#FFFFFF")
            } else {
                cell.containerView.backgroundColor = .white
                cell.textColor = UIColor(hex: "#272722")
            }
        }
        
        return cell
    }
    
}

extension DailyWeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 88
        let height: CGFloat = 36
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        dayNumber = indexPath
        updateUI()
        
    }
    
}

extension DailyWeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather) {
        DispatchQueue.main.async {
            
            self.days = self.getDaysFromWeather(from: weather)
            
            self.dayView.day = self.days[self.dayNumber.item]
            
            self.nightView.day = self.days[self.dayNumber.item]
            
            self.sunAndMoonView.day = self.days[self.dayNumber.item]
            self.sunAndMoonView.timeZoneOffset = weather.timezoneOffset
            
            self.isInCacheMode = false
            self.daysCollectionView.reloadData()
            self.daysCollectionView.selectItem(at: self.dayNumber, animated: true, scrollPosition: .left)
            
            self.spinner.stopAnimating()
            
            // записали в БД (для обновления из кэша в будущем)
            self.city = self.coreDataManager.updateWeather(for: self.city, with: weather)
            
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            print("didFailWithError, DailyWeatherViewController")
            handleApiError(error: .networkError, vc: self)
        }
    }
    
    func didBeginNetworkActivity() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    
}

extension DailyWeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let firstLocation = locations.first {
            weatherManager.fetchWeather(lat: firstLocation.coordinate.latitude, lon: firstLocation.coordinate.longitude)
            locationManager?.stopUpdatingLocation()
        } else {
            print("Невозможн получить координаты")
            locationManager?.stopUpdatingLocation()
            handleApiError(error: .locationNotFound, vc: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError")
        handleApiError(error: .locationNotFound, vc: self)
    }
    
}

extension DailyWeatherViewController: UIScrollViewDelegate {
    
}
