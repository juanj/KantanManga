//
//  UIColor+Extension.swift
//  Kantan-Manga
//
//  Created by Juan on 14/02/21.
//

import UIKit

extension UIColor {
    static func colorOrFail(_ named: String) -> UIColor {
        guard let color = UIColor(named: named) else {
            fatalError("Can't find color named \(named)")
        }
        return color
    }

    static let lightBlue = colorOrFail("LightBlue")
    static let purple = colorOrFail("Purple")
}
