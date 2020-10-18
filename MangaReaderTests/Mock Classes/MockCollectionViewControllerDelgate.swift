//
//  MockCollectionViewControllerDelgate.swift
//  Kantan-Manga
//
//  Created by Juan on 15/09/20.
//

@testable import Kantan_Manga

class MockCollectionViewControllerDelgate: CollectionViewControllerDelegate {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect) {}
    func didSelectDeleteManga(_ collectionViewController: CollectionViewController, manga: Manga) {}
    func didSelectRenameManga(_ collectionViewController: CollectionViewController, manga: Manga, name: String?) {}
    func didSelectMoveManga(_ collectionViewController: CollectionViewController, manga: Manga) {}
}
