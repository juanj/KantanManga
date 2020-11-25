//
//  TestsFactories.swift
//  Kantan-MangaTests
//
//  Created by Juan on 19/11/20.
//

@testable import Kantan_Manga

final class TestsFactories {
    // MARK: Coordinators
    static func createAppCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager()) -> AppCoordinator {
        let appCoordinator = AppCoordinator(navigation: navigable, coreDataManager: coreDataManager)
        return appCoordinator
    }

    static func createAddMangasCoordinator(navigable: Navigable = FakeNavigation(), uploadServer: GCDWebUploader = FakeUploadServer(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), delegate: AddMangasCoordinatorDelegate = FakeAddMangasCoordinatorDelegate()) -> AddMangasCoordinator {
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigable, sourceButton: UIBarButtonItem(), uploadServer: uploadServer, coreDataManager: coreDataManager, delegate: delegate)
        return addMangasCoordinator
    }

    static func createTestableAddMangasCoordinator(navigable: Navigable = FakeNavigation(), uploadServer: GCDWebUploader = FakeUploadServer(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), delegate: AddMangasCoordinatorDelegate = FakeAddMangasCoordinatorDelegate()) -> TestableAddMangasCoordinator {
        let addMangasCoordinator = TestableAddMangasCoordinator(navigation: navigable, sourceButton: UIBarButtonItem(), uploadServer: uploadServer, coreDataManager: coreDataManager, delegate: delegate)
        return addMangasCoordinator
    }

    static func createViewMangaCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), manga: Manga? = nil, delegate: ViewMangaCoordinatorDelegate = FakeViewMangaCoordinatorDelegate(), ocr: ImageOCR = FakeImageOcr()) -> ViewMangaCoordinator {
        let aManga: Manga
        if let manga = manga {
            aManga = manga
        } else {
            aManga = coreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "", collection: nil)!
        }
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: navigable, coreDataManager: coreDataManager, manga: aManga, delegate: delegate, originFrame: .zero, ocr: ocr)

        return viewMangaCoordinator
    }

    static func createTestableViewMangaCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), manga: Manga? = nil, delegate: ViewMangaCoordinatorDelegate = FakeViewMangaCoordinatorDelegate(), ocr: ImageOCR = FakeImageOcr(), mangaDataSource: MangaDataSource? = nil) -> TestableViewMangaCoordinator {
        let aManga: Manga
        if let manga = manga {
            aManga = manga
        } else {
            aManga = coreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "", collection: nil)!
        }
        let viewMangaCoordinator = TestableViewMangaCoordinator(navigation: navigable, coreDataManager: coreDataManager, manga: aManga, delegate: delegate, originFrame: .zero, ocr: ocr, mangaDataSource: mangaDataSource)

        return viewMangaCoordinator
    }

    static func createSettingsCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), delegate: SettingsCoordinatorDelegate = FakeSettingsCoordinatorDelegate()) -> SettingsCoordinator {
        let settingsCoordinator = SettingsCoordinator(navigation: navigable, coreDataManager: coreDataManager, delegate: delegate)
        return settingsCoordinator
    }

    // MARK: ViewControllers
    static func createCollectionViewController() -> CollectionViewController {
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])
        return collectionViewController
    }

    static func createMangaViewController(manga: Manga? = nil, dataSource: MangaDataSource? = nil, delegate: MangaViewControllerDelegate = FakeMangaViewControllerDelegate(), firstTime: Bool = false) -> MangaViewController {
        let aManga: Manga
        if let manga = manga {
            aManga = manga
        } else {
            let inMemoryCoreDataManager = InMemoryCoreDataManager()
            aManga = inMemoryCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        }

        let aDataSource: MangaDataSource
        if let dataSource = dataSource {
            aDataSource = dataSource
        } else {
            aDataSource = MangaDataSource(manga: aManga, readerBuilder: { $1(FakeReader(fileName: $0)) })!
        }

        let mangaViewController = MangaViewController(manga: aManga, dataSource: aDataSource, delegate: delegate, firstTime: firstTime)
        return mangaViewController
    }
}
