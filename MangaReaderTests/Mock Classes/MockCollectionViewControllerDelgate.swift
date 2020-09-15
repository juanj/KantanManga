//
//  MockCollectionViewControllerDelgate.swift
//  Kantan-Manga
//
//  Created by Juan on 15/09/20.
//

@testable import Kantan_Manga

class MockCollectionViewControllerDelgate: CollectionViewControllerDelegate {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect) {}
}
