//
//  MainCoordinator.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 03.06.2021.
//

import Foundation
import UIKit

final class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MainScreenViewController()
//        let vc = OnBoardingViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func gotoSettings() {
        let vc = SettingsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func gotoOnBoarding(vc: OnBoardingViewController) {
//        let vc = OnBoardingViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func gotoDailyWeather(city: CityWeather, dayNumber: IndexPath) {
        let vc = DailyWeatherViewController(city: city, dayNumber: dayNumber)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goto24HoursWeather(city: CityWeather) {
        let vc = Weather24HoursViewController(city: city)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
    }
    
    
}
