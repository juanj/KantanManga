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
    private var resultKanjis = [KanjisGroup]()
    private var radicalsStackView: UIStackView!
    private var kanjiCollectionView: UICollectionView!
    private var pageLabel: UILabel!
    private var page = 0
    private var numberOfPages = 0

    private var lastKnownWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainStackView()
        refreshRadicals()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIScreen.main.bounds.width != lastKnownWidth {
            lastKnownWidth = UIScreen.main.bounds.width
            page = 0
            refreshRadicals()
        }
    }

    private func configureMainStackView() {
        kanjiCollectionView = createKanjiCollectionView()
        kanjiCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let navigationStackView = createNavigationStackView()

        radicalsStackView = UIStackView()
        radicalsStackView.axis = .vertical
        radicalsStackView.spacing = 8

        let contentStackView = UIStackView(arrangedSubviews: [navigationStackView, radicalsStackView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.spacing = 8
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStackView)
        contentStackView.addConstraintsTo(view, sides: [.horizontal, .bottom])

        view.addSubview(kanjiCollectionView)
        kanjiCollectionView.addConstraintsTo(view, sides: [.horizontal, .top])
        kanjiCollectionView.bottomAnchor.constraint(equalTo: contentStackView.topAnchor).isActive = true
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
        kanjiCollectionView.backgroundColor = .clear
        kanjiCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return kanjiCollectionView
    }

    private func createActionButton(systemIcon: String) -> UIButton {
        let scale: UIImage.SymbolScale
        let width: CGFloat
        if traitCollection.horizontalSizeClass == .compact {
            width = 60
            scale = .small
        } else {
            width = 100
            scale = .medium
        }

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: scale)
        let button = KeyboardButton(type: .custom)
        let image = UIImage(systemName: systemIcon, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        return button
    }

    private func createNavigationStackView() -> UIView {
        let clearButton = createActionButton(systemIcon: "xmark")
        clearButton.addTarget(self, action: #selector(clearSelection), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(playSound), for: .touchDown)

        let leftButton = createActionButton(systemIcon: "chevron.left")
        leftButton.addTarget(self, action: #selector(previusPage), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(playSound), for: .touchDown)

        let rightButton = createActionButton(systemIcon: "chevron.right")
        rightButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(playSound), for: .touchDown)

        let changeKeyboardButton = createActionButton(systemIcon: "globe")
        changeKeyboardButton.addTarget(self, action: #selector(changeKeyboard), for: .touchUpInside)
        changeKeyboardButton.addTarget(self, action: #selector(playSound), for: .touchDown)

        let deleteButton = createActionButton(systemIcon: "delete.left")
        deleteButton.addTarget(self, action: #selector(deleteCharacter), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(playDeleteSound), for: .touchDown)

        pageLabel = UILabel()
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        pageLabel.textAlignment = .center
        pageLabel.font = .systemFont(ofSize: 15, weight: .black)

        var arrangedViews: [UIView] = [pageLabel, deleteButton, rightButton, leftButton, clearButton]
        if needsInputModeSwitchKey {
            arrangedViews.append(changeKeyboardButton)
        }
        let navigationStackView = UIStackView(arrangedSubviews: arrangedViews)
        navigationStackView.axis = .vertical
        navigationStackView.distribution = .fillEqually
        navigationStackView.alignment = .fill
        navigationStackView.spacing = 8

        return navigationStackView
    }

    private func createRadicalButton(_ radical: Radical) -> UIButton {
        let size: CGFloat
        let fontSize: CGFloat
        if traitCollection.horizontalSizeClass == .compact {
            size = 40
            fontSize = 15
        } else {
            size = 60
            fontSize = 20
        }

        let button = KeyboardButton()
        button.backgroundColor = selection.contains(radical) ? .lightGray : .white
        button.setTitle("\(radical.onlyRadicalPart()) \(radical.strokeCount)", for: .normal)
        button.tag = Int(radical.rowId)
        button.titleLabel?.font = .systemFont(ofSize: fontSize)
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: size).isActive = true
        button.addTarget(self, action: #selector(selectRadical(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(playSound), for: .touchDown)
        return button
    }

    private func createPlaceHolderButton() -> UIButton {
        let size: CGFloat
        if traitCollection.horizontalSizeClass == .compact {
            size = 40
        } else {
            size = 60
        }

        let placeHolder = UIButton()
        placeHolder.heightAnchor.constraint(equalToConstant: size).isActive = true
        placeHolder.widthAnchor.constraint(equalToConstant: size).isActive = true
        return placeHolder
    }

    private func numberOfRowsColumns() -> (rows: Int, columns: Int) {
        let screenSize = UIScreen.main.bounds
        let fraction: CGFloat = screenSize.height > screenSize.width ? 3.0 : 2.0
        let maxHeight = max(200, (screenSize.height / fraction) - view.safeAreaInsets.bottom - 30)
        let maxWidth = screenSize.width - (view.safeAreaInsets.left + view.safeAreaInsets.right)
        var rows = 1
        var columns = 1
        if traitCollection.horizontalSizeClass == .compact {
            rows = Int(floor((maxHeight - 70) / 44.0))
            columns = Int(floor((maxWidth - 70) / 60))
        } else {
            rows = Int(floor((maxHeight - 70) / 64.0))
            columns = Int(floor((maxWidth - 130) / 64.0))
        }

        return (rows, columns)
    }

    private func refreshRadicals() {
        guard let dictionary = dictionary else { return }
        radicalsStackView.arrangedSubviews.forEach { view in
            radicalsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let gridSize = numberOfRowsColumns()

        validRadicals = dictionary.getValidRadicalsWith(selection: selection)
        numberOfPages = Int(ceil(Float(validRadicals.count) / Float(gridSize.rows * gridSize.columns)))
        pageLabel.text = "\(page + 1)/\(numberOfPages)"

        for row in 0..<gridSize.rows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 8

            let startIndex = row * gridSize.columns + page * (gridSize.rows * gridSize.columns)
            let endIndex = startIndex + gridSize.columns
            for index in startIndex..<endIndex {
                if index < validRadicals.count {
                    let radical = validRadicals[index]
                    let button = createRadicalButton(radical)
                    rowStackView.addArrangedSubview(button)
                } else {
                    let placeHolder = createPlaceHolderButton()
                    rowStackView.addArrangedSubview(placeHolder)
                }
            }

            radicalsStackView.addArrangedSubview(rowStackView)
        }
    }

    private func refreshKanji() {
        guard let dictionary = dictionary else { return }
        let kanjis = dictionary.getKanjiWith(radicals: selection)
        resultKanjis = []
        var lastStrokeCount = 0
        var container = KanjisGroup(kanjis: [], strokeCount: 0)
        for kanji in kanjis {
            if kanji.strokeCount > lastStrokeCount {
                if lastStrokeCount > 0 {
                    resultKanjis.append(container)
                }
                container = KanjisGroup(kanjis: [kanji], strokeCount: kanji.strokeCount)
                lastStrokeCount = kanji.strokeCount
            } else {
                container.kanjis.append(kanji)
            }
        }
        kanjiCollectionView.reloadData()
    }
}

// MARK: Actions
extension KeyboardViewController {
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
        page = 0
        selection = []
        refreshRadicals()
        refreshKanji()
    }
}

// MARK: UICollection
extension KeyboardViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return resultKanjis.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resultKanjis[section].kanjis.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kanjiCell", for: indexPath) as! KanjiCollectionViewCell // swiftlint:disable:this force_cast
        if indexPath.row == 0 {
            cell.kanjiLabel.text = String(resultKanjis[indexPath.section].strokeCount)
            cell.kanjiLabel.backgroundColor = .black
            cell.kanjiLabel.textColor = .white
            cell.layer.cornerRadius = 5
        } else {
            cell.kanjiLabel.text = resultKanjis[indexPath.section].kanjis[indexPath.row - 1].character
        }
        return cell
    }
}

extension KeyboardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let kanji = resultKanjis[indexPath.section].kanjis[indexPath.row - 1]
        textDocumentProxy.insertText(kanji.character)
    }
}
