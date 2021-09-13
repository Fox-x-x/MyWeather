//
//  Errors.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 10.06.2021.
//

import Foundation
import UIKit

enum ApiError: Error {
    case other
    case networkError
    case cityNotFound
    case locationNotFound
}

func handleApiError(error: ApiError, vc: UIViewController) {
    switch error {
    case .other:
        Alert.showAlertError(title: "Oops!", message: "Произошла неизвестная ошибка", on: vc)
    case .networkError:
        Alert.showAlertError(title: "Oops!", message: "Произошла ошибка сетевого запроса", on: vc)
    case .cityNotFound:
        Alert.showAlertError(title: "Oops!", message: "Город не найден", on: vc)
    case .locationNotFound:
        Alert.showAlertError(title: "Oops!", message: "Невозможно получить данные о местонахождении", on: vc)
    
    }
    
}
