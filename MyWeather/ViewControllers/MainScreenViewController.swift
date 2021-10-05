//
//  MainScreenViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit
import CoreData
import CoreLocation

class MainScreenViewController: UIPageViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var cities = [CityWeather]()
    
    private var weatherManager = NetworkManager()
    
    private var locationManager: CLLocationManager?
    private var geolocationAllowed = false
    
    private let defaults = UserDefaults.standard
    
    private var cityManagerViewController: AddCityViewController?
    private var onBoardingViewController = OnBoardingViewController()
    
    private let coreDataManager = CoreDataStack()
    
    var pages = [UIViewController]()
    var initialPage = 0
    
    private lazy var controlsContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray2
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        return pageControl
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "burger"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "burger").alpha(0.8), for: .highlighted)
        button.setBackgroundImage(#imageLiteral(resourceName: "burger").alpha(0.8), for: .selected)
        button.setBackgroundImage(#imageLiteral(resourceName: "burger").alpha(0.5), for: .disabled)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "location"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "location").alpha(0.8), for: .highlighted)
        button.setBackgroundImage(#imageLiteral(resourceName: "location").alpha(0.8), for: .selected)
        button.setBackgroundImage(#imageLiteral(resourceName: "location").alpha(0.5), for: .disabled)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = ""
        label.textColor = UIColor(hex: "#272722")
        label.textAlignment = .center
        return label
    }()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        onBoardingViewController.delegate = self
        
        locationManager = CLLocationManager()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        checkAuthStatus()
        setupPages()
        setupLayout()
        
        navigationController?.isNavigationBarHidden = true
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // проверяем запускалось ли уже приложение и нужно ли показывать онбординг
        if let appHasBeenLaunched = defaults.object(forKey: "hasBeenLaunched") as? Bool {
            if !appHasBeenLaunched {
                defaults.setValue(true, forKey: "hasBeenLaunched")
                coordinator?.gotoOnBoarding(vc: onBoardingViewController)
            }
        } else {
            defaults.setValue(true, forKey: "hasBeenLaunched")
            coordinator?.gotoOnBoarding(vc: onBoardingViewController)
        }
        
    }
    
    @objc private func appMovedFromBackground() {
        if locationManager?.authorizationStatus == .authorizedAlways || locationManager?.authorizationStatus == .authorizedWhenInUse {
            print("In authorizedWhenInUse mode now")
            geolocationAllowed = true
            locationButton.isEnabled = false
            pages = []
            setupPages()
        } else {
            print("auth is not allowed")
            geolocationAllowed = false
            locationButton.isEnabled = true
            pages = []
            setupPages()
        }
    }
    
    // MARK: - setupPages
    private func setupPages() {
        
        let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        let predicate = NSPredicate(format: "geolocated = %d", false)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "self", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        cities = coreDataManager.fetchDataWithRequest(for: CityWeather.self, with: coreDataManager.context, request: request)
        
        let cityManagerViewController = AddCityViewController(coreDataManager: coreDataManager)
        cityManagerViewController.delegate = self
        
        pages.append(UINavigationController(rootViewController: cityManagerViewController))
        
        // если разрешена геолокация, тогда вставляем в pages еще один CityWeatherVC для геоГорода
        if geolocationAllowed {
            
            let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
            let predicate = NSPredicate(format: "geolocated = %d", true)
            request.predicate = predicate
            let geolocatedCities = coreDataManager.fetchDataWithRequest(for: CityWeather.self, with: coreDataManager.context, request: request)
            
            if geolocatedCities.isEmpty {
                // если ГеоГорода еще нет, тогда вошли в режим геолокации в 1-ый раз и нужно создать для этого "город"
                let geolocatedCity = coreDataManager.createObject(from: CityWeather.self, with: coreDataManager.context)
                
                geolocatedCity.geolocated = true
                geolocatedCity.cityName = "Текущее местоположение"
                geolocatedCity.countryName = ""
                geolocatedCity.lat = ""
                geolocatedCity.lon = ""
                
                coreDataManager.save(context: coreDataManager.context)
                
                cities.insert(geolocatedCity, at: 0)

            } else {
                if let geolocatedCity = geolocatedCities.first {
                    cities.insert(geolocatedCity, at: 0)
                }
            }
            
        }
        
        for city in cities {
            let cityWeatherViewController = CityWeatherViewController(city: city)
            cityWeatherViewController.coordinator = coordinator
            pages.append(UINavigationController(rootViewController: cityWeatherViewController))
        }
        
        pageControl.numberOfPages = pages.count
        
        if geolocationAllowed {
            locationLabel.text = "Текущее местоположение"
            pageControl.currentPage = initialPage + 1
            setViewControllers([pages[initialPage + 1]], direction: .forward, animated: true, completion: nil)
        } else {
            locationLabel.text = ""
            pageControl.currentPage = initialPage
            setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Layout
    private func setupLayout() {
        
        view.addSubview(controlsContentView)
        
        controlsContentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
        }
        
        controlsContentView.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(controlsContentView.snp.bottom).offset(-10)
            make.width.equalToSuperview()
            make.height.equalTo(10)
        }
        
        controlsContentView.addSubview(settingsButton)
        
        settingsButton.snp.makeConstraints { make in
            make.bottom.equalTo(pageControl.snp.top).offset(-20)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(36)
            make.height.equalTo(20)
        }
        
        controlsContentView.addSubview(locationButton)
        
        locationButton.snp.makeConstraints { make in
            make.bottom.equalTo(pageControl.snp.top).offset(-20)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(20)
            make.height.equalTo(26)
        }
        
        controlsContentView.addSubview(locationLabel)
        
        locationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(pageControl.snp.top).offset(-20)
            make.leading.equalTo(settingsButton.snp.trailing).offset(8)
            make.trailing.equalTo(locationButton.snp.leading).offset(-8)
        }
        
    }
    
    @objc private func settingsButtonPressed() {
        coordinator?.gotoSettings()
    }
    
    @objc private func locationButtonPressed() {
        coordinator?.gotoOnBoarding(vc: onBoardingViewController)
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }
    
    private func checkAuthStatus() {
        if locationManager?.authorizationStatus == .authorizedAlways || locationManager?.authorizationStatus == .authorizedWhenInUse {
            print("In authorizedWhenInUse mode now")
            geolocationAllowed = true
            locationButton.isEnabled = false
        } else {
            print("auth is not allowed")
            geolocationAllowed = false
            locationButton.isEnabled = true
        }
    }

}

// MARK: - extensions

extension MainScreenViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == 0 {
            return pages.last
        } else {
            return pages[currentIndex - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex < pages.count - 1 {
            return pages[currentIndex + 1]
        } else {
            return pages.first
        }
    }
    
}

extension MainScreenViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        
        if pages[currentIndex].title == "" {
            locationLabel.text = "Текущее местоположение"
        } else {
            locationLabel.text = pages[currentIndex].title
        }
        
        pageControl.currentPage = currentIndex
    }

}

extension MainScreenViewController: AddCityManagerDelegate {
    
    func didAddCity(city: CityWeather) {
        print("city has been added: \(city.cityName)")
        
        let cityWeatherVC = CityWeatherViewController(city: city)
        cityWeatherVC.coordinator = coordinator
        
        if geolocationAllowed {
            cities.insert(city, at: 1)
            pages.insert(UINavigationController(rootViewController: cityWeatherVC), at: 2)
            pageControl.numberOfPages = pages.count
            pageControl.currentPage = initialPage + 2
            locationLabel.text = city.cityName
            setViewControllers([pages[initialPage + 2]], direction: .forward, animated: true, completion: nil)
        } else {
            cities.insert(city, at: 0)
            pages.insert(UINavigationController(rootViewController: cityWeatherVC), at: 1)
            pageControl.numberOfPages = pages.count
            pageControl.currentPage = initialPage + 1
            locationLabel.text = city.cityName
            setViewControllers([pages[initialPage + 1]], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
}

extension MainScreenViewController: LocationStatusChangesDelegate {
    
    func locationAuthStatusDidChange(status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            geolocationAllowed = true
            
            let context = coreDataManager.context
            
            let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
            let predicate = NSPredicate(format: "geolocated = %d", true)
            request.predicate = predicate
            let geolocatedCities = coreDataManager.fetchDataWithRequest(for: CityWeather.self, with: coreDataManager.context, request: request)
            
            var geolocatedCityVC: CityWeatherViewController?
            
            if geolocatedCities.isEmpty {
                // если нет, тогда вошли в режим геолокации в 1-ый раз и нужно создать для этого "город"
                let geolocatedCity = coreDataManager.createObject(from: CityWeather.self, with: context)
                
                geolocatedCity.geolocated = true
                geolocatedCity.cityName = "Текущее местоположение"
                geolocatedCity.countryName = ""
                geolocatedCity.lat = ""
                geolocatedCity.lon = ""
                
                coreDataManager.save(context: context)
                
                cities.insert(geolocatedCity, at: 0)
                geolocatedCityVC = CityWeatherViewController(city: geolocatedCity)

            } else {
                if let geolocatedCity = geolocatedCities.first {
                    cities.insert(geolocatedCity, at: 0)
                    geolocatedCityVC = CityWeatherViewController(city: geolocatedCity)
                }
            }
            
            if let geolocatedCityVC = geolocatedCityVC {
                pages.insert(UINavigationController(rootViewController: geolocatedCityVC), at: 1)
                pageControl.numberOfPages = pages.count
                pageControl.currentPage = initialPage + 1
                setViewControllers([pages[initialPage + 1]], direction: .forward, animated: true, completion: nil)
            }
            
        } else if status == .denied, geolocationAllowed {
            geolocationAllowed = false
            cities.remove(at: 0)
            pages.remove(at: 1)
            pageControl.numberOfPages = pages.count
            pageControl.currentPage = initialPage
            setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        }
    }
    
}
