//
//  KeyboardButton.swift
//  Kantan-Keyboard
//
//  Created by Juan on 24/10/20.
//

import UIKit

class KeyboardButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = 5.0
        layer.masksToBounds = false

        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.35

        backgroundColor = .white
        setTitleColor(.black, for: .normal)
    }
}
