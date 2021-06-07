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
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func gotoSettings() {
        let vc = SettingsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func gotoOnBoarding() {
        let vc = OnBoardingViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}