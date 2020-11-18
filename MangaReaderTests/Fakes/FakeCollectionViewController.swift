//
//  FakeCollectionViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 15/09/20.
//

@testable import Kantan_Manga

class FakeCollectionViewController: CollectionViewController {
    override var collectionView: UICollectionView! {
        get {
            return FakeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        set {
            _ = newValue
        }
    }
}
