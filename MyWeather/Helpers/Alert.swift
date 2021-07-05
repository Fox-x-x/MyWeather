//
//  Alert.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 10.06.2021.
//

import Foundation
import UIKit

final class Alert {

    class func showAlertError(title: String, message: String, on viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
            
        }
        alert.addAction(ok)
        viewController.present(alert, animated: true, completion: nil)
    }
}
