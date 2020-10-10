//
//  CircleView.swift
//  Kantan-Manga
//
//  Created by Juan on 10/10/20.
//

import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}
