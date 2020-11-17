//
//  FakeLibraryViewController.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class FakeLibraryViewController: LibraryViewController {
    private let strongReferenceFakeCollection = FakeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override var collectionView: UICollectionView! {
        get {
            return strongReferenceFakeCollection
        }
        set {
            _ = newValue
        }
    }

    init(collections: [MangaCollectionable] = []) {
        super.init(delegate: FakeLibraryViewControllerDelegate(), collections: collections)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setCollections(collections: [MangaCollectionable]) {}
}
