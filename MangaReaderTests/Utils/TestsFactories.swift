//
//  TestsFactories.swift
//  Kantan-MangaTests
//
//  Created by Juan on 19/11/20.
//

@testable import Kantan_Manga

final class TestsFactories {
    static func createAppCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager()) -> AppCoordinator {
        let appCoordinator = AppCoordinator(navigation: navigable, coreDataManager: coreDataManager)
        return appCoordinator
    }

    static func createAddMangasCoordinator(navigable: Navigable = FakeNavigation(), uploadServer: GCDWebUploader = FakeUploadServer(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), delegate: AddMangasCoordinatorDelegate = FakeAddMangasCoordinatorDelegate()) -> AddMangasCoordinator {
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigable, sourceButton: UIBarButtonItem(), uploadServer: uploadServer, coreDataManager: coreDataManager, delegate: delegate)
        return addMangasCoordinator
    }

    static func createViewMangaCoordinator() -> ViewMangaCoordinator {
        let inMemoryCoreDataManager = InMemoryCoreDataManager()
        let manga = inMemoryCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: FakeNavigation(), coreDataManager: inMemoryCoreDataManager, manga: manga, delegate: FakeViewMangaCoordinatorDelegate(), originFrame: .zero, ocr: FakeImageOcr())

        return viewMangaCoordinator
    }

    static func createCollectionViewController() -> CollectionViewController {
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])
        return collectionViewController
    }
}
