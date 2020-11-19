//
//  AppCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import CoreData

class AppCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private var currentMangaDataSource: MangaDataSource?
    private var libraryView: LibraryViewController?
    private var collectionView: CollectionViewController?
    private var collectionIndexPath: IndexPath?
    private var movingManga: Manga?

    private var navigation: Navigable
    private var coreDataManager: CoreDataManageable
    init(navigation: Navigable, coreDataManager: CoreDataManageable) {
        self.navigation = navigation
        self.coreDataManager = coreDataManager
        super.init()
        self.navigation.delegate = self
    }

    func start() {
        let library = LibraryViewController(delegate: self, collections: loadCollections(), showOnboarding: !UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))
        UserDefaults.standard.setValue(true, forKey: "hasSeenOnboarding")
        navigation.pushViewController(library, animated: false)
        libraryView = library
    }

    func loadCollections() -> [MangaCollectionable] {
        var collections = [MangaCollectionable]()
        if let noCollectionMangas = coreDataManager.getMangasWithoutCollection() {
            collections.append(EmptyMangaCollection(mangas: noCollectionMangas))
        }
        if let allCollections = coreDataManager.fetchAllCollections() {
            collections.append(contentsOf: allCollections)
        }
        return collections.filter { $0.mangas.count > 0 }
    }
}

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem) {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        let uploadServer = GCDWebUploader(uploadDirectory: documentPath)
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigation, sourceButton: button, uploadServer: uploadServer, coreDataManager: coreDataManager, delegate: self)
        childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }

    func didSelectSettings(_ libraryViewController: LibraryViewController) {
        let settingsCoordinator = SettingsCoordinator(navigation: navigation, coreDataManager: coreDataManager, delegate: self)
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()
    }

    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, rotations: [CGAffineTransform]) {
        guard let indexPath = libraryViewController.collectionView.indexPathsForSelectedItems?.first else { return }
        guard var cellCenter = libraryViewController.collectionView.cellForItem(at: indexPath)?.center else { return }
        cellCenter.y -= libraryViewController.collectionView.contentOffset.y + libraryViewController.collectionView.contentInset.top
        collectionIndexPath = indexPath
        let collectionView = CollectionViewController(delegate: self, collection: collection, sourcePoint: cellCenter, initialRotations: rotations)
        navigation.pushViewController(collectionView, animated: true)
        self.collectionView = collectionView
    }

    func didSelectDeleteCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable) {
        guard let collection = collection as? MangaCollection else { return }
        coreDataManager.delete(collection: collection)
        libraryViewController.setCollections(collections: loadCollections())
    }

    func didSelectRenameCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, name: String?) {
        guard let collection = collection as? MangaCollection, let name = name, !name.isEmpty else { return }
        collection.name = name
        coreDataManager.updateCollection(collection)
        libraryViewController.setCollections(collections: loadCollections())
    }

    func didSelectLoadDemoManga(_ libraryViewController: LibraryViewController) {
        libraryView?.dismiss(animated: true, completion: nil)
        coreDataManager.createDemoManga {
            DispatchQueue.main.async {
                libraryViewController.setCollections(collections: self.loadCollections())
            }
        }
    }
}

// MARK: CollectionViewControllerDelegate
extension AppCoordinator: CollectionViewControllerDelegate {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect) {
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: navigation, coreDataManager: coreDataManager, manga: manga, delegate: self, originFrame: cellFrame, ocr: TesseractOCR())
        childCoordinators.append(viewMangaCoordinator)
        viewMangaCoordinator.start()
    }

    func didSelectDeleteManga(_ collectionViewController: CollectionViewController, manga: Manga) {
        coreDataManager.delete(manga: manga)
        coreDataManager.refreshAll()
        collectionViewController.collectionView.reloadSections(IndexSet(integer: 0))
    }

    func didSelectRenameManga(_ collectionViewController: CollectionViewController, manga: Manga, name: String?) {
        guard let name = name, !name.isEmpty else { return }
        manga.name = name
        coreDataManager.updateManga(manga: manga)
    }

    func didSelectMoveManga(_ collectionViewController: CollectionViewController, manga: Manga) {
        let collections = coreDataManager.fetchAllCollections() ?? []
        movingManga = manga
        navigation.present(SelectCollectionTableViewController(delegate: self, collections: collections), animated: true, completion: nil)
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

// MARK: ViewMangaCoordinatorDelegate
extension AppCoordinator: ViewMangaCoordinatorDelegate {
    func didEnd(_ viewMangaCoordinator: ViewMangaCoordinator) {
        removeChildCoordinator(type: ViewMangaCoordinator.self)
        navigation.delegate = self
    }
}

// MARK: SelectCollectionTableViewControllerDelegate
extension AppCoordinator: SelectCollectionTableViewControllerDelegate {
    func selectCollection(_ selectCollectionTableViewController: SelectCollectionTableViewController, collection: MangaCollection) {
        guard let manga = movingManga else { return }
        manga.mangaCollection = collection
        coreDataManager.updateManga(manga: manga)
        coreDataManager.refreshAll()
        collectionView?.collectionView.reloadSections(IndexSet(integer: 0))
        navigation.dismiss(animated: true, completion: nil)
        movingManga = nil
        // TODO: Refresh "No collection" collection
    }

    func addCollection(_ selectCollectionTableViewController: SelectCollectionTableViewController, name: String) {
        guard let manga = movingManga, let collection = coreDataManager.insertCollection(name: name) else { return }
        manga.mangaCollection = collection
        coreDataManager.updateManga(manga: manga)
        coreDataManager.refreshAll()
        collectionView?.collectionView.reloadSections(IndexSet(integer: 0))
        navigation.dismiss(animated: true, completion: nil)
        movingManga = nil
        // TODO: Refresh "No collection" collection
    }
}

// MARK: SettingsCoordinatorDelegate
extension AppCoordinator: SettingsCoordinatorDelegate {
    func didEnd(_ settingsCoordinator: SettingsCoordinator) {
        libraryView?.setCollections(collections: loadCollections())
    }
}

// MARK: UINavigationControllerDelegate
extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard (fromVC is LibraryViewController || fromVC is CollectionViewController) &&
            (toVC is LibraryViewController || toVC is CollectionViewController),
            let indexPath = collectionIndexPath else { return nil }
        if operation == .pop {
            self.collectionIndexPath = nil
        }
        return OpenCollectionAnimationController(operation: operation, indexPath: indexPath)
    }
}
