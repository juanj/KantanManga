//
//  KeyboardViewController.swift
//  Kantan-Keyboard
//
//  Created by Juan on 19/10/20.
//

import UIKit
import AudioToolbox

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
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        mainStackView.addConstraintsTo(view, spacing: .init(top: 8, left: 8, bottom: -8, right: -8))

        kanjiCollectionView = createKanjiCollectionView()
        mainStackView.addArrangedSubview(kanjiCollectionView)

        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 8
        mainStackView.addArrangedSubview(contentStackView)

        radicalsStackView = UIStackView()
        radicalsStackView.axis = .vertical
        radicalsStackView.spacing = 8
        contentStackView.addArrangedSubview(radicalsStackView)

        let navigationStackView = createNavigationStackView()
        contentStackView.addArrangedSubview(navigationStackView)
    }

    private func createKanjiCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        let kanjiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        kanjiCollectionView.dataSource = self
        kanjiCollectionView.delegate = self
        kanjiCollectionView.register(UINib(nibName: "KanjiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "kanjiCell")
        kanjiCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        kanjiCollectionView.backgroundColor = .white
        return kanjiCollectionView
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
        arrowsStackView.spacing = 8
        navigationStackView.addArrangedSubview(arrowsStackView)

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let clearButton = KeyboardButton(type: .custom)
        let clearImage = UIImage(systemName: "xmark", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysOriginal)
        clearButton.setImage(clearImage, for: .normal)
        clearButton.addTarget(self, action: #selector(clearSelection), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(playSound), for: .touchDown)
        clearButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let leftButton = KeyboardButton(type: .custom)
        let leftImage = UIImage(systemName: "chevron.left", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysOriginal)
        leftButton.setImage(leftImage, for: .normal)
        leftButton.addTarget(self, action: #selector(previusPage), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(playSound), for: .touchDown)
        leftButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let rightButton = KeyboardButton(type: .custom)
        let rightImage = UIImage(systemName: "chevron.right", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysOriginal)
        rightButton.setImage(rightImage, for: .normal)
        rightButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(playSound), for: .touchDown)
        rightButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let changeKeyboardButton = KeyboardButton(type: .custom)
        let globeImage = UIImage(systemName: "globe", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysOriginal)
        changeKeyboardButton.setImage(globeImage, for: .normal)
        changeKeyboardButton.addTarget(self, action: #selector(changeKeyboard), for: .touchUpInside)
        changeKeyboardButton.addTarget(self, action: #selector(playSound), for: .touchDown)
        changeKeyboardButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        changeKeyboardButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let deleteButton = KeyboardButton(type: .custom)
        let deleteImage = UIImage(systemName: "delete.left", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysOriginal)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteCharacter), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(playDeleteSound), for: .touchDown)
        deleteButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        arrowsStackView.addArrangedSubview(clearButton)
        arrowsStackView.addArrangedSubview(leftButton)
        arrowsStackView.addArrangedSubview(rightButton)
        arrowsStackView.addArrangedSubview(changeKeyboardButton)
        arrowsStackView.addArrangedSubview(deleteButton)

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
            rowStackView.spacing = 8

            let startIndex = row * 5 + page * 25
            let endIndex = startIndex + 5
            for index in startIndex..<endIndex {
                if index < validRadicals.count {
                    let radical = validRadicals[index]
                    let button = KeyboardButton()
                    button.backgroundColor = selection.contains(radical) ? .lightGray : .white
                    button.setTitle("\(radical.onlyRadicalPart()) \(radical.strokeCount)", for: .normal)
                    button.tag = Int(radical.rowId)
                    button.heightAnchor.constraint(equalToConstant: 60).isActive = true
                    button.widthAnchor.constraint(equalToConstant: 60).isActive = true
                    button.addTarget(self, action: #selector(selectRadical(_:)), for: .touchUpInside)
                    button.addTarget(self, action: #selector(playSound), for: .touchDown)
                    rowStackView.addArrangedSubview(button)
                } else {
                    let placeHolder = UIButton()
                    placeHolder.heightAnchor.constraint(equalToConstant: 60).isActive = true
                    placeHolder.widthAnchor.constraint(equalToConstant: 60).isActive = true
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

    @objc private func playSound() {
        AudioServicesPlaySystemSound(1104)
    }

    @objc private func playDeleteSound() {
        AudioServicesPlaySystemSound(1155)
    }

    @objc private func selectRadical(_ sender: UIButton) {
        guard let radical = validRadicals.first( where: { $0.rowId == sender.tag }) else { return }
        page = 0
        if selection.contains(radical) {
            if let index = selection.firstIndex(of: radical) {
                selection.remove(at: index)
            }
        } else {
            selection.append(radical)
        }
        refreshRadicals()
        refreshKanji()
    }

    @objc private func nextPage() {
        page = min(page + 1, numberOfPages - 1)
        refreshRadicals()
    }

    @objc private func previusPage() {
        page = max(page - 1, 0)
        refreshRadicals()
    }

    @objc private func changeKeyboard() {
        advanceToNextInputMode()
    }

    @objc private func deleteCharacter() {
        textDocumentProxy.deleteBackward()
    }

    @objc private func clearSelection() {
        textDocumentProxy.deleteBackward()
        page = 0
        selection = []
        refreshRadicals()
        refreshKanji()
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

extension KeyboardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let kanji = resultKanjis[indexPath.row]
        textDocumentProxy.insertText(kanji.character)
    }
}
