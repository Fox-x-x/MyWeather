//
//  CityWeatherViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit
import Hex
import CoreData
import CoreLocation

class CityWeatherViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    private var weatherManager = NetworkManager()
    
    private var city: CityWeather
    
    private var hoursCached = [HourCached]()
    private var hours = [Hour]()
    
    private var daysCached = [DayCached]()
    private var days = [Day]()
    
    private var isInCacheMode = false
    
    private let coreDataManager = CoreDataStack()
    private lazy var context = coreDataManager.context
    
    private var locationManager: CLLocationManager?
    
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
    
    private lazy var daySummaryView = DaySummaryView()
    
    private lazy var moreFor24HRSButton: UIButton = {
        
        let button = UIButton()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attributeString = NSMutableAttributedString(
            string: "Подробнее на 24 часа",
            attributes: attributes
        )
        
        button.setAttributedTitle(attributeString, for: .normal)

        button.addTarget(self, action: #selector(moreFor24HRSButtonPressed), for: .touchUpInside)
        
        return button
        
    }()
    
    private lazy var forecast24HRSCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            Forecast24HRSCell.self,
            forCellWithReuseIdentifier: String(describing: Forecast24HRSCell.self)
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var daylyForecastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "Ежедневный прогноз"
        return label
    }()
    
    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BriefWeatherInfoTableViewCell.self, forCellReuseIdentifier: String(describing: BriefWeatherInfoTableViewCell.self))
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    init(city: CityWeather) {
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        weatherManager.weatherDataDelegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = city.cityName
        
        options = loadSettings()
        updateUI()
        
    }
    
    private func updateUI() {
        
        daySummaryView.options = options
        
        if let weatherFromDB = city.weather {
            // обновляем UI данными из БД, конвертируем в WeatherCached и суем в DaySummaryView
            print("Хочу обновиться из кэша :)")
            // обновляемся из кэша, потом идем в сеть
            let weatherDecoder = WeatherDecoder()
            let weather = weatherDecoder.fromDataBase(weatherFromDB: weatherFromDB, coreDataManager: coreDataManager)
            daySummaryView.weatherFromDB = weather
            
            DispatchQueue.main.async {
                self.isInCacheMode = true
                
                self.hoursCached = self.getHoursFromWeather(from: weather)
                self.forecast24HRSCollectionView.reloadData()
                
                self.daysCached = self.getDaysFromWeather(from: weather)
                self.weatherTableView.reloadData()
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
            // в противном случае делаем запрос в сеть и далее идем в метод делегата и там обновляем UI
            print("Иду в сеть...")
            if city.geolocated == true {
                locationManager?.startUpdatingLocation()
            } else {
                weatherManager.fetchWeather(for: city)
            }
            
        }
        
    }
    
    private func setupLayout() {
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-32)
            make.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(daySummaryView)
        
        daySummaryView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(212)
        }
        
        contentView.addSubview(moreFor24HRSButton)
        
        moreFor24HRSButton.snp.makeConstraints { make in
            make.top.equalTo(daySummaryView.snp.bottom).offset(33)
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        contentView.addSubview(forecast24HRSCollectionView)
        
        forecast24HRSCollectionView.snp.makeConstraints { make in
            make.top.equalTo(moreFor24HRSButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        contentView.addSubview(daylyForecastLabel)
        
        daylyForecastLabel.snp.makeConstraints { make in
            make.top.equalTo(forecast24HRSCollectionView.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }
        
        contentView.addSubview(weatherTableView)
        
        weatherTableView.snp.makeConstraints { make in
            make.top.equalTo(daylyForecastLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 1.5)
            make.bottom.equalToSuperview()
        }
        
    }
    
    @objc private func moreFor24HRSButtonPressed() {
        print("goto24HoursWeather pressed")
        coordinator?.goto24HoursWeather(city: city)
    }
    
}

// MARK: - CollectionView extension

extension CityWeatherViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInCacheMode {
            return hoursCached.count
        } else {
            return hours.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Forecast24HRSCell.self), for: indexPath) as! Forecast24HRSCell
        
        cell.options = options
        
        if isInCacheMode {
            cell.hourCached = hoursCached[indexPath.item]
        } else {
            cell.hour = hours[indexPath.item]
        }
        
        return cell
    }
    
}

extension CityWeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 42
        let height: CGFloat = 83
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

// MARK: - TableView extension

extension CityWeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isInCacheMode {
            return daysCached.count
        } else {
            return days.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BriefWeatherInfoTableViewCell.self), for: indexPath) as! BriefWeatherInfoTableViewCell
        
        cell.options = options
        
        if isInCacheMode {
            cell.dayCached = daysCached[indexPath.row]
        } else {
            cell.day = days[indexPath.row]
        }
        
        return cell
    }
    
}

extension CityWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator?.gotoDailyWeather(city: city, dayNumber: indexPath)
    }
    
}

extension CityWeatherViewController: WeatherManagerDelegate {
    
    func didBeginNetworkActivity() {
        DispatchQueue.main.async {
            self.daySummaryView.spinner.startAnimating()
        }
    }
    
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather) {
        DispatchQueue.main.async {
            
            self.daySummaryView.weather = weather
            self.hours = self.getHoursFromWeather(from: weather)
            self.days = self.getDaysFromWeather(from: weather)
            self.isInCacheMode = false
            self.forecast24HRSCollectionView.reloadData()
            self.weatherTableView.reloadData()
            
            self.daySummaryView.spinner.stopAnimating()
            
            // записали в БД (для обновления из кэша в будущем)
            self.city = self.coreDataManager.updateWeather(for: self.city, with: weather)
            
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.daySummaryView.spinner.stopAnimating()
            print("что-то пошло не так, didFailWithError")
            handleApiError(error: .networkError, vc: self)
        }
    }
}

extension CityWeatherViewController: CLLocationManagerDelegate {
    
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
