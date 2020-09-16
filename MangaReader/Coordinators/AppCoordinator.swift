//
//  AppCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import CoreData

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()

    var currentMangaDataSource: MangaDataSource?
    var libraryView: LibraryViewController?

    init(navigation: UINavigationController) {
        navigationController = navigation
    }

    func start() {
        let library = LibraryViewController(delegate: self, collections: loadCollections())
        navigationController.pushViewController(library, animated: false)
        libraryView = library
    }

    func loadCollections() -> [MangaCollectionable] {
        var collections = [MangaCollectionable]()
        if let noCollectionMangas = CoreDataManager.sharedManager.getMangasWithoutCollection() {
            collections.append(EmptyMangaCollection(mangas: noCollectionMangas))
        }
        if let allCollections = CoreDataManager.sharedManager.fetchAllCollections() {
            collections.append(contentsOf: allCollections)
        }
        return collections
    }
}

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem) {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        let uploadServer = GCDWebUploader(uploadDirectory: documentPath)
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigationController, sourceButton: button, uploadServer: uploadServer, delegate: self)
        childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }

    func didSelectSettings(_ libraryViewController: LibraryViewController) {
        let settingsCoordinator = SettingsCoordinator(navigation: navigationController)
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()
    }

    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable) {
        let collectionView = CollectionViewController(delegate: self, collection: collection)
        navigationController.pushViewController(collectionView, animated: true)
    }
}

// MARK: CollectionViewControllerDelegate
extension AppCoordinator: CollectionViewControllerDelegate {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect) {
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: navigationController, manga: manga, delegate: self, originFrame: cellFrame, ocr: TesseractOCR())
        childCoordinators.append(viewMangaCoordinator)
        viewMangaCoordinator.start()
    }
}

// MARK: AddMangasCoordinatorDelegate
extension AppCoordinator: AddMangasCoordinatorDelegate {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator) {
        removeChildCoordinator(type: AddMangasCoordinator.self)
        libraryView?.setCollections(collections: loadCollections())
    }

    func cancel(_ addMangasCoordinator: AddMangasCoordinator) {
        removeChildCoordinator(type: AddMangasCoordinator.self)
    }
}

extension AppCoordinator: ViewMangaCoordinatorDelegate {
    func didEnd(viewMangaCoordinator: ViewMangaCoordinator) {
        removeChildCoordinator(type: ViewMangaCoordinator.self)
    }
}
