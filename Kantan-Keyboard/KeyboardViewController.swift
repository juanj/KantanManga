//
//  KeyboardViewController.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    private let dictionary = RadicalsDictionary()
    private var selection = [Radical]()
    private var validRadicals = [Radical]()
    private var resultKanjis = [Kanji]()
    private var radicalsStackView: UIStackView!
    private var kanjiCollectionView: UICollectionView!
    private var pageLabel: UILabel!
    private var page = 0
    private var numberOfPages = 0

    override func viewDidLoad() {
        configureMainStackView()
        refreshRadicals()
    }

    private func configureMainStackView() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        mainStackView.addConstraintsTo(view)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        kanjiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        kanjiCollectionView.dataSource = self
        kanjiCollectionView.register(UINib(nibName: "KanjiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "kanjiCell")
        kanjiCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        kanjiCollectionView.backgroundColor = .white
        mainStackView.addArrangedSubview(kanjiCollectionView)

        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        mainStackView.addArrangedSubview(contentStackView)

        radicalsStackView = UIStackView()
        radicalsStackView.axis = .vertical
        contentStackView.addArrangedSubview(radicalsStackView)

        let navigationStackView = createNavigationStackView()
        contentStackView.addArrangedSubview(navigationStackView)
    }

    private func createNavigationStackView() -> UIView {
        let navigationStackView = UIStackView()
        navigationStackView.axis = .vertical
        navigationStackView.alignment = .center

        pageLabel = UILabel()
        navigationStackView.addArrangedSubview(pageLabel)

        let arrowsStackView = UIStackView()
        arrowsStackView.axis = .horizontal
        arrowsStackView.distribution = .equalSpacing
        navigationStackView.addArrangedSubview(arrowsStackView)

        let leftButton = UIButton()
        leftButton.setImage(UIImage(systemName: "chevron.left.square.fill"), for: .normal)
        leftButton.addTarget(self, action: #selector(previusPage(_:)), for: .touchUpInside)

        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: "chevron.right.square.fill"), for: .normal)
        rightButton.addTarget(self, action: #selector(nextPage(_:)), for: .touchUpInside)

        arrowsStackView.addArrangedSubview(leftButton)
        arrowsStackView.addArrangedSubview(rightButton)

        return navigationStackView
    }

    private func refreshRadicals() {
        guard let dictionary = dictionary else { return }
        radicalsStackView.arrangedSubviews.forEach { view in
            radicalsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        validRadicals = dictionary.getValidRadicalsWith(selection: selection)
        numberOfPages = Int(ceil(Float(validRadicals.count) / 25.0))
        pageLabel.text = "\(page + 1)/\(numberOfPages)"

        for row in 0..<5 {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal

            let startIndex = row * 5 + page * 25
            let endIndex = startIndex + 5
            for index in startIndex..<endIndex {
                if index < validRadicals.count - 1 {
                    let radical = validRadicals[index]
                    let button = UIButton()
                    button.setTitle(radical.character, for: .normal)
                    button.tag = Int(radical.rowId)
                    button.addTarget(self, action: #selector(selectRadical(_:)), for: .touchUpInside)
                    rowStackView.addArrangedSubview(button)
                } else {
                    let placeHolder = UIButton()
                    rowStackView.addArrangedSubview(placeHolder)
                }
            }

            radicalsStackView.addArrangedSubview(rowStackView)
        }
    }

    private func refreshKanji() {
        guard let dictionary = dictionary else { return }
        resultKanjis = dictionary.getKanjiWith(radicals: selection)
        kanjiCollectionView.reloadData()
    }

    @objc private func selectRadical(_ sender: UIButton) {
        UIDevice.current.playInputClick()
        guard let radical = validRadicals.first( where: { $0.rowId == sender.tag }) else { return }
        page = 0
        selection.append(radical)
        refreshRadicals()
        refreshKanji()
    }

    @objc private func nextPage(_ sender: UIButton) {
        page = min(page + 1, numberOfPages - 1)
        refreshRadicals()
    }

    @objc private func previusPage(_ sender: UIButton) {
        page = max(page - 1, 0)
        refreshRadicals()
    }
}

extension KeyboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resultKanjis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kanjiCell", for: indexPath) as! KanjiCollectionViewCell // swiftlint:disable:this force_cast
        cell.kanjiLabel.text = resultKanjis[indexPath.row].character
        return cell
    }
}
