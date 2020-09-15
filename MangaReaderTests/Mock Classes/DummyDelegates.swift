//
//  DummyDelegates.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class DummyLibraryViewControllerDelegate: LibraryViewControllerDelegate {
    func didSelectSettings(_ libraryViewController: LibraryViewController) {}
    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollection) {}
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem) {}
}
