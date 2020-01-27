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

class AnalyzeTextView: UIControl {
    var sentence: String {
        didSet {
            analyzeText()
        }
    }
    weak var delegate: AnalyzeTextViewDelegate?
    var isDictionaryOpen: Bool {
        return dictionaryTableViewHeightConstraint.constant > 0
    }
    var dictionaryHeight: CGFloat {
        return dictionaryTableViewHeightConstraint.constant
    }

    private var analyzedSentence = [JapaneseWord]()
    private var maxHeight: CGFloat

    private let margin: CGFloat = 20
    private var buttons = [UIButton]()
    private var labels = [UILabel]()
    private var textView = UIView()
    private var scrollView = UIScrollView()
    private var editButton = UIButton()
    private var dictionaryResults = [DictionaryResult]()
    private var dictionaryTableView = UITableView()
    private var dictionaryTableViewHeightConstraint: NSLayoutConstraint!
    private var textField = UITextField()
    private var editing = false

    init(sentence: String = "", maxHeight: CGFloat = 500) {
        self.sentence = sentence
        self.maxHeight = maxHeight
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
        configureEditButton()
        configureTextField()
        configurePanGesture()
        analyzeText()
    }

    private func configureBlur() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        let topConstraint = blurView.topAnchor.constraint(equalTo: topAnchor)
        let leftConstraint = blurView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = blurView.rightAnchor.constraint(equalTo: rightAnchor)
        let heightConstraint = blurView.heightAnchor.constraint(equalToConstant: 100)

        addConstraints([topConstraint, leftConstraint, rightConstraint, heightConstraint])
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
        dictionaryTableViewHeightConstraint = dictionaryTableView.heightAnchor.constraint(equalToConstant: 0)

        addConstraints([topScrollViewConstraint, leftScrollViewConstraint, rightScrollViewConstraint, heightScrollViewConstraint, topDictionaryTableViewConstraint, leftDictionaryTableViewConstraint, rightDictionaryTableViewConstraint, bottomDictionaryTableViewConstraint, dictionaryTableViewHeightConstraint])
    }

    private func configureScrollView() {
        scrollView.bounces = false
    }

    private func configureEditButton() {
        editButton.setBackgroundImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)

        addSubview(editButton)

        let topConstraint = editButton.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        let rightConstraint = editButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
        let heightConstraint = editButton.heightAnchor.constraint(equalToConstant: 25)
        let widthConstraint = editButton.widthAnchor.constraint(equalToConstant: 25)

        addConstraints([topConstraint, rightConstraint, heightConstraint, widthConstraint])
    }

    private func configureTextField() {
        textField.delegate = self
        textField.isHidden = true
        textField.font = .systemFont(ofSize: 50, weight: .bold)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        let rightConstraint = textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin)
        let leftConstraint = textField.leftAnchor.constraint(equalTo: leftAnchor, constant: margin)
        let topConstraint = textField.topAnchor.constraint(equalTo: topAnchor, constant: margin)
        let heightContraint = textField.heightAnchor.constraint(equalToConstant: 75)

        addConstraints([rightConstraint, leftConstraint, topConstraint, heightContraint])
    }

    private func configureTableView() {
        dictionaryTableView.delegate = self
        dictionaryTableView.dataSource = self
        dictionaryTableView.isScrollEnabled = false
    }

    private func loadText() {
        if editing { toggleEdit() }
        buttons.forEach { $0.removeFromSuperview() }
        labels.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        labels.removeAll()
        for (index, word) in analyzedSentence.enumerated() {
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
            if index == analyzedSentence.count - 1 {
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
        bringSubviewToFront(editButton)
    }

    private func configureStyle() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
    }

    private func configurePanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(pan:)))
        panGesture.delegate = self
        textView.addGestureRecognizer(panGesture)
    }

    private func toggleEdit() {
        editing = !editing
        if editing {
            closeDictionary()
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
        analyzedSentence = tokens.map {JapaneseWord(text: $0.surface, rootForm: $0.originalForm ?? $0.surface, furigana: getFurigana(token: $0))}
        loadText()
    }

    func closeDictionary(animated: Bool = false) {
        guard isDictionaryOpen else { return }
        if animated {
            dictionaryTableViewHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }) { (_) in
                self.dictionaryResults = []
                self.dictionaryTableView.reloadData()
            }
        } else {
            dictionaryResults = []
            dictionaryTableView.reloadData()
        }
    }

    @objc func openDetail(button: UIButton) {
        dictionaryResults = JapaneseDictionary.shared.findWord(word: analyzedSentence[button.tag].rootForm)
        dictionaryTableView.setContentOffset(.zero, animated: false)
        dictionaryTableView.reloadData()
    }

    @objc func edit() {
        toggleEdit()
    }

    @objc func handlePan(pan: UIPanGestureRecognizer) {
        delegate?.handlePan(analyzeTextView: self, pan: pan)
    }
}

extension AnalyzeTextView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = dictionaryResults.count
        if sections > 0 && dictionaryTableViewHeightConstraint.constant == 0 {
            dictionaryTableViewHeightConstraint.constant = 100
        } else if sections == 0 {
            dictionaryTableViewHeightConstraint.constant = 0
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
        dictionaryTableViewHeightConstraint.constant = min(tableView.contentSize.height, maxHeight)
        if dictionaryTableViewHeightConstraint.constant == maxHeight {
            tableView.isScrollEnabled = true
        } else {
            tableView.isScrollEnabled = false
        }
        layoutIfNeeded()
        return cell
    }
}

extension AnalyzeTextView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sentence = textField.text ?? ""
        analyzeText()
        return true
    }
}

extension AnalyzeTextView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panGestureRecognizer.velocity(in: textView)
        return abs(velocity.y) > abs(velocity.x)
    }
}

protocol AnalyzeTextViewDelegate: AnyObject {
    func handlePan(analyzeTextView: AnalyzeTextView, pan: UIPanGestureRecognizer)
}
