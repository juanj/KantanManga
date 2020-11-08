//
//  FakeLibraryViewControllerDelegate.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class FakeLibraryViewControllerDelegate: LibraryViewControllerDelegate {
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem) {}
    func didSelectSettings(_ libraryViewController: LibraryViewController) {}
    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, rotations: [CGAffineTransform]) {}
    func didSelectDeleteCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable) {}
    func didSelectRenameCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, name: String?) {}
    func didSelectLoadDemoManga(_ libraryViewController: LibraryViewController) {}
}
