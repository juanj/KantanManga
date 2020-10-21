//
//  KeyboardViewController.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    let dictionary = RadicalsDictionary()
    override func viewDidLoad() {
        let mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        mainStackView.addConstraintsTo(view)
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center

        let radicalsStackView = UIStackView()
        radicalsStackView.axis = .vertical
        mainStackView.addArrangedSubview(radicalsStackView)

        guard let dictionary = dictionary else { return }
        let entries = dictionary.getRadicals()
        for row in 0..<5 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal

            let startIndex = row * 5
            let endIndex = startIndex + 5
            for rowEntry in entries[startIndex..<endIndex] {
                let button = UIButton()
                button.setTitle(rowEntry.character, for: .normal)
                rowStackView.addArrangedSubview(button)
            }

            radicalsStackView.addArrangedSubview(rowStackView)
        }

        let navigationStackView = UIStackView()
        navigationStackView.axis = .vertical
        navigationStackView.alignment = .center
        mainStackView.addArrangedSubview(navigationStackView)

        let pageLabel = UILabel()
        pageLabel.text = "\(1)/\(ceil(Float(entries.count) / 25.0))"

        navigationStackView.addArrangedSubview(pageLabel)

        let arrowsStackView = UIStackView()
        arrowsStackView.axis = .horizontal
        arrowsStackView.distribution = .equalSpacing
        navigationStackView.addArrangedSubview(arrowsStackView)

        let leftButton = UIButton()
        leftButton.setImage(UIImage(systemName: "chevron.left.square.fill"), for: .normal)

        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: "chevron.right.square.fill"), for: .normal)

        arrowsStackView.addArrangedSubview(leftButton)
        arrowsStackView.addArrangedSubview(rightButton)
    }
}
