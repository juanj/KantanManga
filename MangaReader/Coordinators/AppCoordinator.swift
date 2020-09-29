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

    private var navigationController: UINavigationController
    init(navigation: UINavigationController) {
        navigationController = navigation
        super.init()
        navigationController.delegate = self
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
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigationController, sourceButton: button, uploadServer: uploadServer, delegate: self)
        childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }

    func didSelectSettings(_ libraryViewController: LibraryViewController) {
        let settingsCoordinator = SettingsCoordinator(navigation: navigationController)
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()
    }

    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, rotations: [CGAffineTransform]) {
        guard let indexPath = libraryViewController.collectionView.indexPathsForSelectedItems?.first else { return }
        guard let cellCenter = libraryViewController.collectionView.cellForItem(at: indexPath)?.center else { return }
        collectionIndexPath = indexPath
        let collectionView = CollectionViewController(delegate: self, collection: collection, sourcePoint: cellCenter, initialRotations: rotations)
        navigationController.pushViewController(collectionView, animated: true)
        self.collectionView = collectionView
    }

    func didSelectDeleteCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable) {
        guard let collection = collection as? MangaCollection else { return }
        CoreDataManager.sharedManager.delete(collection: collection)
        libraryViewController.setCollections(collections: loadCollections())
    }

    func didSelectRenameCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, name: String?) {
        guard let collection = collection as? MangaCollection, let name = name, !name.isEmpty else { return }
        collection.name = name
        CoreDataManager.sharedManager.updateCollection(collection)
        libraryViewController.setCollections(collections: loadCollections())
    }
}

// MARK: CollectionViewControllerDelegate
extension AppCoordinator: CollectionViewControllerDelegate {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect) {
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: navigationController, manga: manga, delegate: self, originFrame: cellFrame, ocr: TesseractOCR())
        childCoordinators.append(viewMangaCoordinator)
        viewMangaCoordinator.start()
    }

    func didSelectDeleteManga(_ collectionViewController: CollectionViewController, manga: Manga) {
        CoreDataManager.sharedManager.delete(manga: manga)
        CoreDataManager.sharedManager.refreshAll()
        collectionViewController.collectionView.reloadSections(IndexSet(integer: 0))
    }

    func didSelectRenameManga(_ collectionViewController: CollectionViewController, manga: Manga, name: String?) {
        guard let name = name, !name.isEmpty else { return }
        manga.name = name
        CoreDataManager.sharedManager.updateManga(manga: manga)
    }

    func didSelectMoveManga(_ collectionViewController: CollectionViewController, manga: Manga) {
        let collections = CoreDataManager.sharedManager.fetchAllCollections() ?? []
        movingManga = manga
        navigationController.present(SelectCollectionTableViewController(delegate: self, collections: collections), animated: true, completion: nil)
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
        navigationController.delegate = self
    }
}

extension AppCoordinator: SelectCollectionTableViewControllerDelegate {
    func selectCollection(selectCollectionTableViewController: SelectCollectionTableViewController, collection: MangaCollection) {
        guard let manga = movingManga else { return }
        manga.mangaCollection = collection
        CoreDataManager.sharedManager.updateManga(manga: manga)
        CoreDataManager.sharedManager.refreshAll()
        collectionView?.collectionView.reloadSections(IndexSet(integer: 0))
        navigationController.dismiss(animated: true, completion: nil)
        movingManga = nil
        // TODO: Refresh "No collection" collection
    }

    func addCollection(selectCollectionTableViewController: SelectCollectionTableViewController, name: String) {
        guard let manga = movingManga, let collection = CoreDataManager.sharedManager.insertCollection(name: name) else { return }
        manga.mangaCollection = collection
        CoreDataManager.sharedManager.updateManga(manga: manga)
        CoreDataManager.sharedManager.refreshAll()
        collectionView?.collectionView.reloadSections(IndexSet(integer: 0))
        navigationController.dismiss(animated: true, completion: nil)
        movingManga = nil
        // TODO: Refresh "No collection" collection
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
