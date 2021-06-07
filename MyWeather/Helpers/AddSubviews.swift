//
//  AddSubviews.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 18.05.2021.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
}
