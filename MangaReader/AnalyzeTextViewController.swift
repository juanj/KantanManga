//
//  AnalyzeTextViewController.swift
//  MangaReader
//
//  Created by Juan on 5/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

struct Furigana {
    let kana: String
    let range: NSRange
}

struct JapaneseWord {
    let text: String
    let rootForm: String
    let furigana: [Furigana]
}

class AnalyzeTextViewController: UIControl {
    var sentence: [JapaneseWord] {
        didSet {
            loadText()
        }
    }
    private let margin: CGFloat = 20
    private var buttons = [UIButton]()
    private var labels = [UILabel]()

    init(sentence: [JapaneseWord]) {
        self.sentence = sentence
        super.init(frame: CGRect.zero)

        initView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView() {
        translatesAutoresizingMaskIntoConstraints = false
        configureBlur()
        configureStyle()
        loadText()

    }

    private func configureBlur() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        let topConstraint = blurView.topAnchor.constraint(equalTo: topAnchor)
        let leftConstraint = blurView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = blurView.rightAnchor.constraint(equalTo: rightAnchor)
        let bottomConstraint = blurView.bottomAnchor.constraint(equalTo: bottomAnchor)

        addConstraints([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }

    private func loadText() {
        buttons.forEach { $0.removeFromSuperview() }
        labels.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        labels.removeAll()
        for word in sentence {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
            button.setTitle(word.text, for: .normal)
            button.sizeToFit()
            addSubview(button)

            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 100)
            let topConstraint = button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            let bottomConstraint = button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            let leadingConstraint: NSLayoutConstraint
            if let lastButton = buttons.last {
                leadingConstraint = button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor, constant: margin)
            } else {
                leadingConstraint = button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin)
            }

            addConstraints([topConstraint, bottomConstraint, leadingConstraint, heightConstraint])
            buttons.append(button)

            for furigana in word.furigana {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = furigana.kana
                label.sizeToFit()
                addSubview(label)

                let characterWidth = button.frame.width / CGFloat(word.text.count)
                let center = (((CGFloat(furigana.range.length) * characterWidth) / 2) + characterWidth * CGFloat(furigana.range.location)) - label.frame.width / 2

                let bottomConstraint = label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 25)
                let leftConstraint = label.leftAnchor.constraint(equalTo: button.leftAnchor, constant: center)

                addConstraints([bottomConstraint, leftConstraint])
                labels.append(label)
            }
        }
    }

    private func configureStyle() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
    }
}
