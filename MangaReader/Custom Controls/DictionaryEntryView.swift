//
//  DictionaryEntryView.swift
//  MangaReader
//
//  Created by DevBakura on 28/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

class DictionaryEntryView: UIView {
    private let entry: DictionaryResult
    init(entry: DictionaryResult) {
        self.entry = entry
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let title = UILabel()
        title.font = .systemFont(ofSize: 40)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.text = entry.word.joined(separator: ", ")

        let body = UILabel()
        body.font = .systemFont(ofSize: 20)
        body.translatesAutoresizingMaskIntoConstraints = false
        body.numberOfLines = 0
        body.text = entry.meanings.map { "• " + $0 } .joined(separator: "\n")

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray

        addSubview(title)
        addSubview(body)
        addSubview(separator)

        // Title constraints
        let titleTopConstraint = title.topAnchor.constraint(equalTo: topAnchor)
        let titleLeftConstraint = title.leftAnchor.constraint(equalTo: leftAnchor)
        let titleRightConstraint = title.rightAnchor.constraint(equalTo: rightAnchor)

        // Body constraints
        let bodyTopConstraint = body.topAnchor.constraint(equalTo: title.bottomAnchor)
        let bodyLeftConstraint = body.leftAnchor.constraint(equalTo: leftAnchor)
        let bodyRightConstraint = body.rightAnchor.constraint(equalTo: rightAnchor)
        let bodyBottomConstraint = body.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)

        // Separator constraints
        let separatorLeftConstraint = separator.leftAnchor.constraint(equalTo: leftAnchor)
        let separatorRightConstraint = separator.rightAnchor.constraint(equalTo: rightAnchor)
        let separatorBottomConstraint = separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        let separatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: (1.0 / UIScreen.main.scale))

        addConstraints([titleTopConstraint, titleLeftConstraint, titleRightConstraint, bodyTopConstraint, bodyLeftConstraint, bodyRightConstraint, bodyBottomConstraint, separatorLeftConstraint, separatorRightConstraint, separatorBottomConstraint, separatorHeightConstraint])
    }
}
