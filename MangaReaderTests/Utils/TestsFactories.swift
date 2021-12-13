//
//  TestsFactories.swift
//  Kantan-MangaTests
//
//  Created by Juan on 19/11/20.
//

@testable import Kantan_Manga
import GRDB

final class TestsFactories {
    // MARK: Coordinators
    static func createLibraryCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager()) -> LibraryCoordinator {
        let libraryCoordinator = LibraryCoordinator(navigation: navigable, coreDataManager: coreDataManager)
        return libraryCoordinator
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

    static func createTestableViewMangaCoordinator(navigable: Navigable = FakeNavigation(), coreDataManager: CoreDataManageable = InMemoryCoreDataManager(), manga: Manga? = nil, delegate: ViewMangaCoordinatorDelegate = FakeViewMangaCoordinatorDelegate(), ocr: ImageOCR = FakeImageOcr(), mangaDataSource: MangaDataSourceable? = nil) -> TestableViewMangaCoordinator {
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

    static func createDictionariesCoordinator(navigable: Navigable = FakeNavigation(), decoder: DictionaryDecoder = FakeDictionaryDecoder(), compoundDictionary: CompoundDictionary = FakeCompoundDictionary()) -> DictionariesCoordinator {
        let dictionariesCoordinator = DictionariesCoordinator(navigation: navigable, compoundDictionary: compoundDictionary, dictionaryDecoder: decoder)
        return dictionariesCoordinator
    }

    static func createEditSentenceCoordinator(navigable: Navigable = FakeNavigation(), image: UIImage = UIImage(), word: String = "", reading: String = "", sentence: String = "", definition: String = "", delegate: EditSentenceCoordinatorDelegate = FakeEditSentenceCoordinatorDelegate()) -> EditSentenceCoordinator {
        let editSentenceCoordinator = EditSentenceCoordinator(navigation: navigable, image: image, word: word, reading: reading, sentence: sentence, definition: definition, delegate: delegate)
        return editSentenceCoordinator
    }

    static func createTestableEditSentenceCoordinator(navigable: Navigable = FakeNavigation(), image: UIImage = UIImage(), word: String = "", reading: String = "", sentence: String = "", definition: String = "", delegate: EditSentenceCoordinatorDelegate = FakeEditSentenceCoordinatorDelegate()) -> TestableEditSentenceCoordinator {
    let editSentenceCoordinator = TestableEditSentenceCoordinator(navigation: navigable, image: image, word: word, reading: reading, sentence: sentence, definition: definition, delegate: delegate)
        return editSentenceCoordinator
    }

    // MARK: ViewControllers
    static func createCollectionViewController() -> CollectionViewController {
        let collectionViewController = FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: [])
        return collectionViewController
    }

    static func createMangaViewController(manga: Manga? = nil, dataSource: MangaDataSourceable? = nil, delegate: MangaViewControllerDelegate = FakeMangaViewControllerDelegate(), firstTime: Bool = false, testable: Bool = false) -> MangaViewController {
        let aManga: Manga
        if let manga = manga {
            aManga = manga
        } else {
            let inMemoryCoreDataManager = InMemoryCoreDataManager()
            aManga = inMemoryCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        }

        let aDataSource: MangaDataSourceable
        if let dataSource = dataSource {
            aDataSource = dataSource
        } else {
            aDataSource = MangaDataSource(manga: aManga, readerBuilder: { $1(FakeReader(fileName: $0)) })!
        }

        if testable {
            let mangaViewController = TestableMangaViewController(manga: aManga, dataSource: aDataSource, delegate: delegate, firstTime: firstTime)
            return mangaViewController
        } else {
            let mangaViewController = MangaViewController(manga: aManga, dataSource: aDataSource, delegate: delegate, firstTime: firstTime)
            return mangaViewController
        }
    }

    static func createCreateSentenceViewController(image: UIImage = UIImage(), word: String = "", reading: String = "", sentence: String = "", definition: String = "", isExistingSentence: Bool = false, delegate: CreateSentenceViewControllerDelegate = FakeCreateSentenceViewControllerDelegate()) -> CreateSentenceViewController {
        return CreateSentenceViewController(image: image, word: word, reading: reading, sentence: sentence, definition: definition, isExistingSentence: isExistingSentence, delegate: delegate)
    }
    // MARK: Database
    static func createTestDatabase() -> DatabaseQueue {
        var configuration = Configuration()
        configuration.label = "TEST Dictionaries"
        configuration.foreignKeysEnabled = true
        let db = DatabaseQueue(configuration: configuration)
        let migrator = DBMigrator()
        try! migrator.migrate(db: db) // swiftlint:disable:this force_try
        return db
    }
}
