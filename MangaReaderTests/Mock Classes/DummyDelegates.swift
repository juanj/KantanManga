//
//  DummyDelegates.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import MangaReader

class DummyLibraryViewControllerDelegate: LibraryViewControllerDelegate {
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem) {}
    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga, cellFrame: CGRect) {}
    func didSelectDeleteManga(_ libraryViewController: LibraryViewController, manga: Manga) {}
}
