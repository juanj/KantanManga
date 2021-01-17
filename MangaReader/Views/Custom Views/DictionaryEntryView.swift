//
//  DictionaryEntryView.swift
//  MangaReader
//
//  Created by Juan on 28/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

extension NSAttributedString.Key {
    static let rubyAnnotation: NSAttributedString.Key = kCTRubyAnnotationAttributeName as NSAttributedString.Key
}

class DictionaryEntryView: UIView {
    private let result: SearchResult
    init(result: SearchResult) {
        self.result = result
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        let annotation = CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, result.term.reading as CFString, [
            kCTForegroundColorAttributeName: UIColor.label,
            kCTRubyAnnotationSizeFactorAttributeName: 0.3
        ] as CFDictionary)

        let annotatedString = NSAttributedString(string: result.term.expression, attributes: [
            .foregroundColor: UIColor.label,
            .rubyAnnotation: annotation
        ])

        let title = UILabel()
        title.isUserInteractionEnabled = false
        title.font = .systemFont(ofSize: 40)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.attributedText = annotatedString

        let tagLabel = UILabel()
        tagLabel.text = result.dictionary.title
        tagLabel.textColor = .white
        tagLabel.font = .systemFont(ofSize: 15, weight: .bold)

        let tag = UIView()
        tag.backgroundColor = .purple
        tag.layer.cornerRadius = 5
        tag.addSubview(tagLabel)
        tag.translatesAutoresizingMaskIntoConstraints = false

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.addConstraintsTo(tag, spacing: .init(top: 5, left: 5, bottom: -5, right: -5))

        let body = UITextView()
        body.isEditable = false
        body.font = .systemFont(ofSize: 20)
        body.translatesAutoresizingMaskIntoConstraints = false
        body.isScrollEnabled = false
        body.text = result.term.glossary
            .compactMap { item in
                if case .text(let text) = item {
                    return text
                }
                return nil
            }
            .map { "• " + $0 } .joined(separator: "\n")

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray

        addSubview(title)
        addSubview(tag)
        addSubview(body)
        addSubview(separator)

        title.heightAnchor.constraint(equalToConstant: 75).isActive = true
        title.addConstraintsTo(self, sides: [.horizontal, .top])
        tag.addConstraintsTo(self, sides: [.left])
        tag.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        body.addConstraintsTo(self, sides: [.horizontal, .bottom], spacing: .init(bottom: -10))
        body.topAnchor.constraint(equalTo: tag.bottomAnchor).isActive = true

        // Separator constraints
        separator.addConstraintsTo(self, sides: [.horizontal, .bottom])
        separator.heightAnchor.constraint(equalToConstant: (1.0 / UIScreen.main.scale)).isActive = true
    }
}
