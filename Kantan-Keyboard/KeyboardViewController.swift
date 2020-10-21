//
//  KeyboardViewController.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    private let dictionary = RadicalsDictionary()
    private var selection = [Radical]()
    private var validRadicals = [Radical]()
    private var radicalsStackView: UIStackView!
    private var pageLabel: UILabel!

    override func viewDidLoad() {
        let mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        mainStackView.addConstraintsTo(view)
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center

        radicalsStackView = UIStackView()
        radicalsStackView.axis = .vertical
        mainStackView.addArrangedSubview(radicalsStackView)

        let navigationStackView = UIStackView()
        navigationStackView.axis = .vertical
        navigationStackView.alignment = .center
        mainStackView.addArrangedSubview(navigationStackView)

        pageLabel = UILabel()
        navigationStackView.addArrangedSubview(pageLabel)

        let arrowsStackView = UIStackView()
        arrowsStackView.axis = .horizontal
        arrowsStackView.distribution = .equalSpacing
        navigationStackView.addArrangedSubview(arrowsStackView)

        let leftButton = UIButton()
        leftButton.setImage(UIImage(systemName: "chevron.left.square.fill"), for: .normal)
        leftButton.addTarget(self, action: #selector(selectRadical(_:)), for: .touchUpInside)

        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: "chevron.right.square.fill"), for: .normal)
        rightButton.addTarget(self, action: #selector(selectRadical(_:)), for: .touchUpInside)

        arrowsStackView.addArrangedSubview(leftButton)
        arrowsStackView.addArrangedSubview(rightButton)

        refreshRadicals()
    }

    private func refreshRadicals() {
        guard let dictionary = dictionary else { return }
        radicalsStackView.arrangedSubviews.forEach { view in
            radicalsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        validRadicals = dictionary.getValidRadicalsWith(selection: selection)
        let maxRows = min(5, Int(ceil(Float(validRadicals.count) / 5.0)))
        for row in 0..<maxRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal

            let startIndex = row * 5
            let endIndex = min(startIndex + 5, validRadicals.count - 1)
            for radical in validRadicals[startIndex..<endIndex] {
                let button = UIButton()
                button.setTitle(radical.character, for: .normal)
                button.tag = Int(radical.rowId)
                button.addTarget(self, action: #selector(selectRadical(_:)), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
            }

            radicalsStackView.addArrangedSubview(rowStackView)
        }

        pageLabel.text = "\(1)/\(Int(ceil(Float(validRadicals.count) / 25.0)))"
    }

    @objc private func selectRadical(_ sender: UIButton) {
        guard let radical = validRadicals.first( where: { $0.rowId == sender.tag }) else { return }
        selection.append(radical)
        refreshRadicals()
    }
}
