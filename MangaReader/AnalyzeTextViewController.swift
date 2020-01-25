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
    private var textView = UIView()
    private var scrollView = UIScrollView()
    private var dictionaryResults = [DictionaryResult]()
    private var dictionaryTableView = UITableView()
    private var dictionaryTableViewHeightConstraint: NSLayoutConstraint!

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
        configureStyle()
        configureBlur()
        configureMainConstraints()
        configureTableView()
        configureScrollView()
        loadText()

    }

    private func configureBlur() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(blurView)

        let topConstraint = blurView.topAnchor.constraint(equalTo: textView.topAnchor)
        let leftConstraint = blurView.leftAnchor.constraint(equalTo: textView.leftAnchor)
        let rightConstraint = blurView.rightAnchor.constraint(equalTo: textView.rightAnchor)
        let bottomConstraint = blurView.bottomAnchor.constraint(equalTo: textView.bottomAnchor)

        textView.addConstraints([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }

    private func configureMainConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        dictionaryTableView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(textView)
        addSubview(dictionaryTableView)
        addSubview(scrollView)

        let topTextViewConstraint = textView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        let leftTextViewConstraint = textView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        let rightTextViewConstraint = textView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        let bottomTextViewConstraint = textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        let heightTextViewConstraint = textView.heightAnchor.constraint(equalToConstant: 100)
        let minWidthTextViewConstraint = textView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor, multiplier: 1)

        scrollView.addConstraints([heightTextViewConstraint, topTextViewConstraint, leftTextViewConstraint, rightTextViewConstraint, bottomTextViewConstraint, minWidthTextViewConstraint])

        let topScrollViewConstraint = scrollView.topAnchor.constraint(equalTo: topAnchor)
        let leftScrollViewConstraint = scrollView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightScrollViewConstraint = scrollView.rightAnchor.constraint(equalTo: rightAnchor)
        let heightScrollViewConstraint = scrollView.heightAnchor.constraint(equalToConstant: 100)

        let topDictionaryTableViewConstraint = dictionaryTableView.topAnchor.constraint(equalTo: scrollView.bottomAnchor)
        let leftDictionaryTableViewConstraint = dictionaryTableView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightDictionaryTableViewConstraint = dictionaryTableView.rightAnchor.constraint(equalTo: rightAnchor)
        let bottomDictionaryTableViewConstraint = dictionaryTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        dictionaryTableViewHeightConstraint = dictionaryTableView.heightAnchor.constraint(equalToConstant: 200)

        addConstraints([topScrollViewConstraint, leftScrollViewConstraint, rightScrollViewConstraint, heightScrollViewConstraint, topDictionaryTableViewConstraint, leftDictionaryTableViewConstraint, rightDictionaryTableViewConstraint, bottomDictionaryTableViewConstraint, dictionaryTableViewHeightConstraint])
    }

    private func configureScrollView() {
        scrollView.bounces = false
    }

    private func configureTableView() {
        dictionaryTableView.delegate = self
        dictionaryTableView.dataSource = self
        dictionaryTableView.isScrollEnabled = false
    }

    private func loadText() {
        buttons.forEach { $0.removeFromSuperview() }
        labels.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        labels.removeAll()
        for (index, word) in sentence.enumerated() {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 50, weight: .bold)
            button.setTitle(word.text, for: .normal)
            button.sizeToFit()
            button.tag = index
            button.addTarget(self, action: #selector(openDetail(button:)), for: .touchUpInside)
            textView.addSubview(button)

            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 100)
            let topConstraint = button.topAnchor.constraint(equalTo: textView.safeAreaLayoutGuide.topAnchor)
            let bottomConstraint = button.bottomAnchor.constraint(equalTo: textView.safeAreaLayoutGuide.bottomAnchor)
            let leadingConstraint: NSLayoutConstraint
            if let lastButton = buttons.last {
                leadingConstraint = button.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor, constant: margin)
            } else {
                leadingConstraint = button.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: margin)
            }
            if index == sentence.count - 1 {
                let trailingConstraint = button.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -margin)
                textView.addConstraint(trailingConstraint)
            }

            textView.addConstraints([topConstraint, bottomConstraint, leadingConstraint, heightConstraint])
            buttons.append(button)

            for furigana in word.furigana {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = furigana.kana
                label.sizeToFit()
                textView.addSubview(label)

                let characterWidth = button.frame.width / CGFloat(word.text.count)
                let center = (((CGFloat(furigana.range.length) * characterWidth) / 2) + characterWidth * CGFloat(furigana.range.location)) - label.frame.width / 2

                let bottomConstraint = label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 25)
                let leftConstraint = label.leftAnchor.constraint(equalTo: button.leftAnchor, constant: center)

                textView.addConstraints([bottomConstraint, leftConstraint])
                labels.append(label)
            }
        }
    }

    private func configureStyle() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
    }

    @objc func openDetail(button: UIButton) {
        dictionaryResults = JapaneseDictionary.shared.findWord(word: sentence[button.tag].rootForm)
        dictionaryTableView.reloadData()
    }
}

extension AnalyzeTextViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = dictionaryResults.count
        if sections > 0 && dictionaryTableViewHeightConstraint.constant == 0 {
            dictionaryTableViewHeightConstraint.constant = 100
        }
        return sections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dictionaryResults[section].word.joined(separator: " , ")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryResults[section].meanings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        cell.textLabel?.text = dictionaryResults[indexPath.section].meanings[indexPath.row]
        dictionaryTableViewHeightConstraint.constant = tableView.contentSize.height
        layoutIfNeeded()
        return cell
    }
}
