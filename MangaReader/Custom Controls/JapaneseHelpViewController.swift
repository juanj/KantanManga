//
//  JapaneseHelpViewController.swift
//  MangaReader
//
//  Created by Juan on 29/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

class JapaneseHelpViewController: UIViewController {
    private var dictView = DictionaryView(maxHeight: 500)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        let inputView = ParsedInputField(delegate: self)

        inputView.translatesAutoresizingMaskIntoConstraints = false
        dictView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(inputView)
        view.addSubview(dictView)

        let inputViewLeftConstraint = inputView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let inputViewRightConstraint = inputView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let inputViewTopConstraint = inputView.topAnchor.constraint(equalTo: view.topAnchor)

        let dictViewLeftConstraint = dictView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let dictViewTopConstraint = dictView.topAnchor.constraint(equalTo: inputView.bottomAnchor)
        let dictViewRightConstraint = dictView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let dictViewBottomConstraint = dictView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        view.addConstraints([inputViewLeftConstraint, inputViewRightConstraint, inputViewTopConstraint, dictViewLeftConstraint, dictViewTopConstraint, dictViewRightConstraint, dictViewBottomConstraint])
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
    }
}
