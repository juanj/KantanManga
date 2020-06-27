//
//  DictionaryView.swift
//  MangaReader
//
//  Created by Juan on 28/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

class DictionaryView: UIView {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var entries = [DictionaryResult]()
    private var entriesViews = [DictionaryEntryView]()
    private let maxHeight: CGFloat
    private var scrollViewHeightConstraint: NSLayoutConstraint!

    init(maxHeight: CGFloat) {
        self.maxHeight = maxHeight
        super.init(frame: .zero)
        configureScrollView()
        configureStackView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        let leftConstraint = scrollView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = scrollView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = scrollView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)

        scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: 0)
        addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint, scrollViewHeightConstraint])
        scrollView.backgroundColor = .systemBackground
    }

    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        scrollView.addSubview(stackView)
        let leftConstraint = stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20)
        let rightConstraint = stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 20)
        let topConstraint = stackView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        let widthConstraint = stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        scrollView.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint, widthConstraint])
    }

    func setEntries(entries: [DictionaryResult]) {
        for entryView in entriesViews {
            stackView.removeArrangedSubview(entryView)
            entryView.removeFromSuperview()
        }
        entriesViews.removeAll()
        self.entries = entries
        for entry in entries {
            let entryView = DictionaryEntryView(entry: entry)
            stackView.addArrangedSubview(entryView)
            entriesViews.append(entryView)
        }
        stackView.layoutIfNeeded()
        scrollViewHeightConstraint?.constant = min(stackView.frame.height, maxHeight)
        layoutIfNeeded()
    }
}
