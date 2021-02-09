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
    private var entries = [SearchResult]()
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
        scrollView.addConstraintsTo(self, sides: .vertical)
        scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: 0)
        scrollViewHeightConstraint.isActive = true
        scrollView.backgroundColor = .systemBackground
    }

    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        scrollView.addSubview(stackView)

        stackView.addConstraintsTo(scrollView, spacing: .init(left: 20, right: -20))
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true

        // Add this zero frame view so the stackview can calculate its frame even when ther are no entries.
        let zeroView = UIView(frame: .zero)
        stackView.addArrangedSubview(zeroView)
    }

    func setEntries(entries: [SearchResult]) {
        for entryView in entriesViews {
            stackView.removeArrangedSubview(entryView)
            entryView.removeFromSuperview()
        }
        entriesViews.removeAll()
        self.entries = entries
        for entry in entries {
            let entryView = DictionaryEntryView(result: entry)
            stackView.addArrangedSubview(entryView)
            entriesViews.append(entryView)
        }
        stackView.layoutIfNeeded()
        scrollViewHeightConstraint?.constant = min(stackView.frame.height, maxHeight)
        layoutIfNeeded()
    }

    func scrollToTop() {
        scrollView.contentOffset = .zero
    }
}
