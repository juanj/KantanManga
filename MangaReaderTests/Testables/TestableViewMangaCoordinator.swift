//
//  TestableViewMangaCoordinator.swift
//  Kantan-MangaTests
//
//  Created by Juan on 24/11/20.
//

@testable import Kantan_Manga

class TestableViewMangaCoordinator: ViewMangaCoordinator {
    var mangaDataSource: MangaDataSourceable?

    init(navigation: Navigable, coreDataManager: CoreDataManageable, manga: Manga, delegate: ViewMangaCoordinatorDelegate, originFrame: CGRect, ocr: ImageOCR, mangaDataSource: MangaDataSourceable? = nil) {
        self.mangaDataSource = mangaDataSource
        super.init(navigation: navigation, coreDataManager: coreDataManager, manga: manga, delegate: delegate, originFrame: originFrame, ocr: ocr)
    }

    override func createMangaDataSource(manga: Manga, readerBuilder: (String, @escaping (Reader) -> Void) -> Void) -> MangaDataSourceable? {
        if let mangaDataSource = mangaDataSource {
            return mangaDataSource
        } else {
            return super.createMangaDataSource(manga: manga, readerBuilder: readerBuilder)
        }
    }
}
