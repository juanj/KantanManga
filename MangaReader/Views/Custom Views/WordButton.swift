//
//  WordButton.swift
//  Kantan-Manga
//
//  Created by Juan on 2/08/20.
//

import Foundation

class WordButton: UIControl {
    override var isSelected: Bool {
        didSet {
            refresh()
        }
    }

    private let word: JapaneseWord
    private var furiganaLabels = [UILabel]()
    private let contentLabel = UILabel()

    init(word: JapaneseWord) {
        self.word = word
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFuriganaLocation()
    }

    private func configure() {
        layer.cornerRadius = 15

        createFurigana()
        configureContentLabel()
    }

    private func createFurigana() {
        for furigana in word.furigana {
            let label = createLabelForFurigana(furigana: furigana)
            addSubview(label)
            furiganaLabels.append(label)
        }
        updateFuriganaLocation()
    }

    private func createLabelForFurigana(furigana: Furigana) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = furigana.kana
        label.textColor = .black
        label.sizeToFit()
        return label
    }

    private func updateFuriganaLocation() {
        for (furigana, label) in zip(word.furigana, furiganaLabels) {
            let characterWidth = contentLabel.frame.width / CGFloat(word.text.count)
            let center = (((CGFloat(furigana.range.length) * characterWidth) / 2) + characterWidth * CGFloat(furigana.range.location)) - label.frame.width / 2
            label.frame.origin = CGPoint(x: 10 + center, y: 0)
        }
    }

    private func configureContentLabel() {
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = .systemFont(ofSize: 50, weight: .bold)
        contentLabel.text = word.text
        contentLabel.textColor = .black
        addSubview(contentLabel)

        contentLabel.addConstraintsTo(self, sides: .horizontal, spacing: .init(left: 10, right: -10))
        contentLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 7).isActive = true
    }

    private func refresh() {
        if isSelected {
            backgroundColor = .black
            contentLabel.textColor = .white
            for furigana in furiganaLabels {
                furigana.textColor = .white
            }
        } else {
            backgroundColor = .clear
            contentLabel.textColor = .black
            for furigana in furiganaLabels {
                furigana.textColor = .black
            }
        }
    }
}
