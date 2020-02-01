//
//  AutoCompleteTextField.swift
//  MangaReader
//
//  Created by Juan on 1/02/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation
import UIKit

protocol AutoCompleteTextFieldDelegate: AnyObject {
    func autoCompleteResultForText(autoCompleteTextField: AutoCompleteTextField, text: String) -> String?
    func didSelectText(autoCompleteTextField: AutoCompleteTextField, text: String)
}

class AutoCompleteTextField: UITextView {
    weak var autoCompleteDelegate: AutoCompleteTextFieldDelegate?
    private var autoCompletedLength = 0
    private var ignoreCursoreOnce = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self

        layer.borderColor = UIColor.placeholderText.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }

    private func autoCompleteWithText(text: String) {
        guard let autoCompletedText = autoCompleteDelegate?.autoCompleteResultForText(autoCompleteTextField: self, text: text) else {
            resetTextField(text: text)
            return
        }
        autoCompletedLength = max(autoCompletedText.count - text.count, 0)
        let attributedString = NSMutableAttributedString(string: autoCompletedText, attributes: [:])
        attributedString.addAttribute(.foregroundColor, value: UIColor.placeholderText, range: NSRange(location: text.count, length: autoCompletedLength))
        ignoreCursoreOnce = true
        attributedText = attributedString
        if let cursorPosition = position(from: beginningOfDocument, offset: text.count) {
            selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
        }
    }

    private func resetTextField(text: String = "") {
        autoCompletedLength = 0
        attributedText = nil
        self.text = text
    }
}

extension AutoCompleteTextField: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            guard let text = textView.text, !text.isEmpty else { return false }
            if autoCompletedLength > 0 {
                resetTextField(text: text)
            } else {
                autoCompleteDelegate?.didSelectText(autoCompleteTextField: self, text: text)
                resetTextField()
            }
            return false
        }

        guard let allText = textView.text as NSString? else { return true }
        let userText = String(allText.replacingCharacters(in: range, with: text).dropLast(autoCompletedLength))

        if userText.isEmpty {
            resetTextField()
            return true
        } else {
            autoCompleteWithText(text: userText)
            return false
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard !ignoreCursoreOnce, let range = textView.selectedTextRange, let text = text else {
            ignoreCursoreOnce = false
            return
        }
        if let autoCompleteStartPosition = textView.position(from: beginningOfDocument, offset: text.count - autoCompletedLength), compare(range.end, to: autoCompleteStartPosition) == .orderedDescending {
            print(compare(range.end, to: autoCompleteStartPosition).rawValue)
            resetTextField(text: text)
        }
    }
}
