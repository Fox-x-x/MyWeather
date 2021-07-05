//
//  MainScreenViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit

class MainScreenViewController: UIPageViewController {
    
    weak var coordinator: MainCoordinator?
    
    private var cities = [CityWeather]()
    
    private var cityManagerViewController: AddCityViewController?
    
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
//        pageControl.numberOfPages = pages.count
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupPages()
        pageControl.currentPage = initialPage
        setupLayout()
        
        navigationController?.isNavigationBarHidden = true
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    private func setupPages() {
        
        let cityManagerViewController = AddCityViewController(coreDataManager: coreDataManager)
        cityManagerViewController.delegate = self
        
        pages.append(UINavigationController(rootViewController: cityManagerViewController))
        
        for city in cities {
            pages.append(UINavigationController(rootViewController: CityWeatherViewController(city: city)))
        }
        
        print("pages count = \(pages.count)")
        pageControl.numberOfPages = pages.count
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
    }
    
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
        print("burger pressed!")
        coordinator?.gotoSettings()
    }
    
    @objc private func locationButtonPressed() {
        print("locations pressed!")
        coordinator?.gotoOnBoarding()
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }

}

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
        
        locationLabel.text = pages[currentIndex].title
        
        pageControl.currentPage = currentIndex
    }

}

extension MainScreenViewController: AddCityManagerDelegate {
    
    func didAddCity(city: CityWeather) {
        print("city has been added: \(city.cityName)")
        cities.append(city)
        pages.append(UINavigationController(rootViewController: CityWeatherViewController(city: city)))
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage + 1
        locationLabel.text = city.cityName
        setViewControllers([pages[initialPage + 1]], direction: .forward, animated: true, completion: nil)
    }
    
}

//extension UIPageViewController {
//    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
//        if let currentViewController = viewControllers?[0] {
//            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
//                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
//            }
//        }
//    }
//}


