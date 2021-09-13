//
//  Weather24HoursViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 15.08.2021.
//

import UIKit
import SnapKit
import Charts
import CoreLocation

class Weather24HoursViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var city: CityWeather
    
    private var weatherManager = NetworkManager()
    
    private var hoursCached = [HourCached]()
    private var hours = [Hour]()
    
    private var temperatureValues = [ChartDataEntry]()
    
    private var options = OptionsStack(temperature: .celsius, winSpeed: .kilometers, timeFormat: .hours24)
    
    private let coreDataManager = CoreDataStack()
    private lazy var context = coreDataManager.context
    
    private var locationManager: CLLocationManager?
    
    private var isInCacheMode = false
    
    private lazy var navigationViewTap = UITapGestureRecognizer(target: self, action: #selector(navigationViewTapped))
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
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
        label.text = "--"
        return label
    }()
    
    private lazy var diagramsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.914, green: 0.933, blue: 0.98, alpha: 1)
        return view
    }()
    
    private lazy var lineChartView: LineChartView = {
        let view = LineChartView()
        view.leftAxis.enabled = false
        view.rightAxis.enabled = false
        view.xAxis.enabled = false
        view.legend.enabled = false
        view.extraTopOffset = 20
        view.animate(xAxisDuration: 0.5)
        
        return view
    }()
    
    private lazy var extraChartView = ExtraChartView()
    
    private lazy var hoursCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            HourCell.self,
            forCellWithReuseIdentifier: String(describing: HourCell.self)
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    // MARK: - Init
    
    init(city: CityWeather) {
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.title = "Прогноз на 24 часа"
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
    
    private func setChartData() {
        
        let temperaturesSet = LineChartDataSet(entries: temperatureValues)
        
        temperaturesSet.setCircleColor(.white)
        temperaturesSet.circleRadius = 4
        temperaturesSet.circleHoleRadius = 4
        
        temperaturesSet.lineWidth = 0.5
        temperaturesSet.setColor(UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1))
        
        temperaturesSet.drawHorizontalHighlightIndicatorEnabled = false
        temperaturesSet.drawVerticalHighlightIndicatorEnabled = false
        
        temperaturesSet.valueFont = UIFont.systemFont(ofSize: 14, weight: .light)

        temperaturesSet.valueFormatter = DefaultValueFormatter(decimals: 0)
        
        let gradientColors = [
                UIColor(red: 0.241, green: 0.412, blue: 0.863, alpha: 1).cgColor,
                UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 1).cgColor,
                UIColor(red: 0.125, green: 0.306, blue: 0.78, alpha: 0).cgColor
        ] as CFArray
        
        let colorLocations: [CGFloat] = [0, 0, 1]
        
        if let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) {
            temperaturesSet.fill = Fill(linearGradient: gradient, angle: 0)
        }
        
        temperaturesSet.drawFilledEnabled = true
        
        let chartData = LineChartData(dataSet: temperaturesSet)
        lineChartView.data = chartData
    }
    
    private func updateUI() {
        
        extraChartView.options = options
        
        if let weatherFromDB = city.weather {
            let weatherDecoder = WeatherDecoder()
            let weather = weatherDecoder.fromDataBase(weatherFromDB: weatherFromDB, coreDataManager: coreDataManager)
            
            DispatchQueue.main.async {
                self.isInCacheMode = true
                
                self.hoursCached = self.getHoursFromWeather(from: weather)

                self.hoursCollectionView.reloadData()
                
                self.temperatureValues = self.getPointsForChart(cachedHours: self.hoursCached, hours: self.hours, options: self.options, isInCacheMode: self.isInCacheMode)
                self.setChartData()
                self.extraChartView.hoursCached = self.hoursCached
                
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
    
    private func setupLayout() {
        
        view.backgroundColor = .white
        
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
        
        contentView.addSubview(diagramsView)
        
        diagramsView.snp.makeConstraints { make in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(152)
        }
        
        diagramsView.addSubview(lineChartView)
        lineChartView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(47)
        }
        
        diagramsView.addSubview(extraChartView)
        extraChartView.snp.makeConstraints { make in
            make.top.equalTo(lineChartView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        contentView.addSubview(hoursCollectionView)
        
        hoursCollectionView.snp.makeConstraints { make in
            make.top.equalTo(diagramsView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1200)
            make.bottom.equalToSuperview().offset(-16)
        }
        
    }
    
    @objc private func navigationViewTapped() {
        coordinator?.goBack()
    }

}

// MARK: - CollectionView extension

extension Weather24HoursViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInCacheMode {
            return hoursCached.count
        } else {
            return hours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HourCell.self), for: indexPath) as! HourCell
        
        cell.options = options
        
        if isInCacheMode {
            cell.hourCached = hoursCached[indexPath.item]
        } else {
            cell.hour = hours[indexPath.item]
        }
        
        return cell
    }
    
}

extension Weather24HoursViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = 150
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
}

// MARK: - Weather manager extension

extension Weather24HoursViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather) {
        DispatchQueue.main.async {
            
            self.hours = self.getHoursFromWeather(from: weather)

            self.isInCacheMode = false
            self.hoursCollectionView.reloadData()
            
            // записали в БД (для обновления из кэша в будущем)
            self.city = self.coreDataManager.updateWeather(for: self.city, with: weather)
            
            self.temperatureValues = self.getPointsForChart(cachedHours: self.hoursCached, hours: self.hours, options: self.options, isInCacheMode: self.isInCacheMode)
            self.setChartData()
            self.extraChartView.hours = self.hours
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            print("что-то пошло не так")
            handleApiError(error: .networkError, vc: self)
        }
    }
    
    func didBeginNetworkActivity() {
    }
    
}

extension Weather24HoursViewController: CLLocationManagerDelegate {
    
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

// MARK: - Scroll view extension
extension Weather24HoursViewController: UIScrollViewDelegate {
    
}
