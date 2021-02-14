//
//  DictionaryKanjiEntryView.swift
//  Kantan-Manga
//
//  Created by Juan on 14/02/21.
//

import Foundation

class DictionaryKanjiEntryView: UIView {
    private let kanji: FullKanjiResult
    init(kanji: FullKanjiResult) {
        self.kanji = kanji
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let characterLabel = UILabel()
        characterLabel.isUserInteractionEnabled = false
        characterLabel.font = .systemFont(ofSize: 40)
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        characterLabel.numberOfLines = 0
        characterLabel.text = kanji.kanji.character

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        let dictionaryTag = createTag(text: kanji.dictionary.title, backgroundColor: .purple)
        let otherTags = kanji.kanji.tags.split(separator: " ")
            .map { createTag(text: String($0), backgroundColor: .lightBlue) }

        let tagsStackView = UIStackView(arrangedSubviews: [dictionaryTag] + otherTags + [UIView()])
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        stackView.addArrangedSubview(tagsStackView)

        let body = """
        Onyomi: \(kanji.kanji.onyomi.replacingOccurrences(of: " ", with: "  "))
        Kunyomi: \(kanji.kanji.kunyomi.replacingOccurrences(of: " ", with: "  "))
        Meaning: \(kanji.kanji.meanings.reduce("", { $0 + "\n- " + $1 }))
        \(kanji.kanji.stats.reduce("", { $0 + "\n" + $1.key + ": " + $1.value }))
        """
        let bodyTextView = UITextView()
        bodyTextView.isEditable = false
        bodyTextView.font = .systemFont(ofSize: 20)
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.isScrollEnabled = false
        bodyTextView.text = body

        stackView.addArrangedSubview(bodyTextView)

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray

        addSubview(characterLabel)
        addSubview(stackView)
        addSubview(separator)

        characterLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
        characterLabel.addConstraintsTo(self, sides: [.horizontal, .top])
        stackView.addConstraintsTo(self, sides: [.horizontal, .bottom], spacing: .init(bottom: -10))
        stackView.topAnchor.constraint(equalTo: characterLabel.bottomAnchor).isActive = true

        // Separator constraints
        separator.addConstraintsTo(self, sides: [.horizontal, .bottom])
        separator.heightAnchor.constraint(equalToConstant: (1.0 / UIScreen.main.scale)).isActive = true
    }

    private func createTag(text: String, backgroundColor: UIColor) -> UIView {
        let tagLabel = UILabel()
        tagLabel.text = text
        tagLabel.textColor = .white
        tagLabel.font = .systemFont(ofSize: 15, weight: .bold)

        let tag = UIView()
        tag.backgroundColor = backgroundColor
        tag.layer.cornerRadius = 5
        tag.addSubview(tagLabel)

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.addConstraintsTo(tag, spacing: .init(top: 5, left: 5, bottom: -5, right: -5))

        return tag
    }
}
