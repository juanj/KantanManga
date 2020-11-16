//
//  ParsedInputField.swift
//  MangaReader
//
//  Created by Juan on 5/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

struct Furigana: Equatable {
    let kana: String
    let range: NSRange
}

struct JapaneseWord {
    let text: String
    let rootForm: String
    let furigana: [Furigana]
}

class ParsedInputField: UIControl {
    var sentence: String {
        didSet {
            analyzeText()
        }
    }
    weak var delegate: ParsedInputFieldDelegate?

    private var analyzedSentence = [JapaneseWord]()

    private let margin: CGFloat = 20
    private var buttons = [WordButton]()
    private var labels = [UILabel]()
    private var textView = UIView()
    private var scrollView = UIScrollView()
    private var editButton = UIButton()
    private var textField = UITextField()
    private var editing = false

    init(delegate: ParsedInputFieldDelegate, sentence: String = "") {
        self.delegate = delegate
        self.sentence = sentence
        super.init(frame: .zero)
        initView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView() {
        configureStyle()
        configureBlur()
        configureMainConstraints()
        configureScrollView()
        configureEditButton()
        configureTextField()
        loadText()
        analyzeText()
    }

    private func configureStyle() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
    }

    private func configureBlur() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        blurView.addConstraintsTo(self, sides: [.horizontal, .top])
        blurView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

    private func configureMainConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(textView)
        addSubview(scrollView)

        textView.addConstraintsTo(scrollView)
        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        textView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor, multiplier: 1).isActive = true

        scrollView.addConstraintsTo(self)
        scrollView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

    private func configureScrollView() {
        scrollView.bounces = false
    }

    private func configureEditButton() {
        editButton.setBackgroundImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)

        addSubview(editButton)

        editButton.addConstraintsTo(self, sides: [.top, .right], spacing: .init(top: 5, right: -5))
        editButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }

    private func configureTextField() {
        textField.delegate = self
        textField.isHidden = true
        textField.font = .systemFont(ofSize: 50, weight: .bold)
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textField)

        textField.addConstraintsTo(scrollView, sides: [.horizontal, .top], spacing: .init(top: margin, left: margin, right: -margin))
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }

    private func loadText() {
        if editing { toggleEdit() }
        buttons.forEach { $0.removeFromSuperview() }
        labels.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        labels.removeAll()
        for (index, word) in analyzedSentence.enumerated() {
            let button = createButtonForWord(word: word, index: index)
            textView.addSubview(button)
            textView.addConstraints(createConstraintsForWordButton(button: button, index: index))
            buttons.append(button)
        }
        bringSubviewToFront(editButton)
    }

    private func createButtonForWord(word: JapaneseWord, index: Int = 0) -> WordButton {
        let button = WordButton(word: word)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        button.addTarget(self, action: #selector(openDetail(button:)), for: .touchUpInside)

        return button
    }

    private func createConstraintsForWordButton(button: WordButton, index: Int = 0) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(button.heightAnchor.constraint(equalToConstant: 80))
        constraints.append(button.centerYAnchor.constraint(equalTo: textView.centerYAnchor))
        if let lastButton = buttons.last {
            constraints.append(button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor))
        } else {
            constraints.append(button.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: margin))
        }
        if index == analyzedSentence.count - 1 {
            constraints.append(button.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -margin))
        }

        return constraints
    }

    private func createLabelForFurigana(furigana: Furigana) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = furigana.kana
        label.textColor = .black
        label.sizeToFit()

        return label
    }

    private func createConstraintsForFuriganaLabel(label: UILabel, button: UIButton, word: JapaneseWord, furigana: Furigana) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        let characterWidth = button.frame.width / CGFloat(word.text.count)
        let center = (((CGFloat(furigana.range.length) * characterWidth) / 2) + characterWidth * CGFloat(furigana.range.location)) - label.frame.width / 2
        constraints.append(label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 25))
        constraints.append(label.leftAnchor.constraint(equalTo: button.leftAnchor, constant: center))

        return constraints
    }

    private func toggleEdit() {
        editing = !editing
        if editing {
            delegate?.willBeginEditing(self)
            textView.alpha = 0
            textView.isUserInteractionEnabled = false
            textField.isHidden = false
            textField.text = analyzedSentence.map { $0.text }.joined(separator: "  ")
            textField.becomeFirstResponder()
        } else {
            textView.alpha = 1
            textView.isUserInteractionEnabled = true
            textField.isHidden = true
            textField.resignFirstResponder()
        }
    }

    private func analyzeText() {
        let tokenizer = Tokenizer()
        let tokens = tokenizer.parse(sentence)
        let words = WordPaser.parse(tokens: tokens)
        analyzedSentence = words.map { JapaneseWord(text: $0.word, rootForm: $0.tokens[0].originalForm ?? $0.word, furigana: FuriganaUtils.getFurigana(text: $0.word, reading: $0.reading)) }
        loadText()
    }

    @objc func openDetail(button: UIButton) {
        buttons.forEach { $0.isSelected = false }
        button.isSelected = true
        let word = analyzedSentence[button.tag]
        delegate?.didSelectWord(self, word: word)
    }

    @objc func edit() {
        toggleEdit()
    }
}

extension ParsedInputField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sentence = textField.text ?? ""
        analyzeText()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.willBeginEditing(self)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if editing {
            toggleEdit()
        }
    }
}

protocol ParsedInputFieldDelegate: AnyObject {
    //func handlePan(analyzeTextView: ParsedInputField, pan: UIPanGestureRecognizer)
    func willBeginEditing(_ parsedInputField: ParsedInputField)
    func didSelectWord(_ parsedInputField: ParsedInputField, word: JapaneseWord)
}
