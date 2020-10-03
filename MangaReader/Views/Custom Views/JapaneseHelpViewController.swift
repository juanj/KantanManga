//
//  JapaneseHelpViewController.swift
//  MangaReader
//
//  Created by Juan on 29/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

class JapaneseHelpViewController: UIViewController {
    var isDictionaryOpen: Bool {
        return dictView.frame.height > 0
    }
    var dictionaryHeight: CGFloat {
        return dictView.frame.height
    }

    private weak var delegate: JapaneseHelpViewControllerDelegate?

    private var dictView = DictionaryView(maxHeight: 500)
    private var parsedInputView: ParsedInputField!

    init(delegate: JapaneseHelpViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        parsedInputView = ParsedInputField(delegate: self)
        parsedInputView.translatesAutoresizingMaskIntoConstraints = false
        dictView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(parsedInputView)
        view.addSubview(dictView)

        let parsedInputViewLeftConstraint = parsedInputView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let parsedInputViewRightConstraint = parsedInputView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let parsedInputViewTopConstraint = parsedInputView.topAnchor.constraint(equalTo: view.topAnchor)

        let dictViewLeftConstraint = dictView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let dictViewTopConstraint = dictView.topAnchor.constraint(equalTo: parsedInputView.bottomAnchor)
        let dictViewRightConstraint = dictView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let dictViewBottomConstraint = dictView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        view.addConstraints([parsedInputViewLeftConstraint, parsedInputViewRightConstraint, parsedInputViewTopConstraint, dictViewLeftConstraint, dictViewTopConstraint, dictViewRightConstraint, dictViewBottomConstraint])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(pan:)))
        panGesture.delegate = self
        parsedInputView.addGestureRecognizer(panGesture)
    }

    func setSentence(text: String) {
        parsedInputView.sentence = text
    }

    @objc func handlePan(pan: UIPanGestureRecognizer) {
        delegate?.handlePan(japaneseHelpViewController: self, pan: pan)
    }
}

extension JapaneseHelpViewController: ParsedInputFieldDelegate {
    func willBeginEditing(parsedInputField: ParsedInputField) {
        dictView.setEntries(entries: [])
    }

    func didSelectWord(parsedInputField analyzeTextView: ParsedInputField, word: JapaneseWord) {
        let dict = JapaneseDictionary()
        let words = dict.findWord(word: word.rootForm)
        dictView.setEntries(entries: words)
        delegate?.didOpenDictionary(japaneseHelpViewController: self)
    }
}

extension JapaneseHelpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }

        // Only trigger when the gesture is vertical
        let velocity = panGestureRecognizer.velocity(in: inputView)
        return abs(velocity.y) > abs(velocity.x)
    }
}

protocol JapaneseHelpViewControllerDelegate: AnyObject {
    func handlePan(japaneseHelpViewController: JapaneseHelpViewController, pan: UIPanGestureRecognizer)
    func didOpenDictionary(japaneseHelpViewController: JapaneseHelpViewController)
}
