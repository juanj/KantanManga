//
//  AppCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import CoreData

class AppCoordinator: NSObject {
    var navigationController: UINavigationController
    var childCoordinators = [Any]()

    var currentMangaDataSource: MangaDataSource?
    var libraryView: LibraryViewController?

    init(navigation: UINavigationController) {
        navigationController = navigation
    }

    func start() {
        let library = LibraryViewController()
        library.delegate = self
        library.mangas = loadMangas()
        navigationController.pushViewController(library, animated: false)
        libraryView = library
    }

    func loadMangas() -> [Manga] {
        return CoreDataManager.sharedManager.fetchAllMangas() ?? [Manga]()
    }
}

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectDeleteManga(_ libraryViewController: LibraryViewController, manga: Manga) {
        CoreDataManager.sharedManager.delete(manga: manga)
        libraryViewController.mangas = loadMangas()
        libraryViewController.collectionView.reloadData()
    }

    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga) {
        let viewMangaCoordinator = ViewMangaCoordinator(navigation: navigationController, manga: manga, delegate: self)
        childCoordinators.append(viewMangaCoordinator)
        viewMangaCoordinator.start()
    }

    func didSelectAdd(_ libraryViewController: LibraryViewController) {
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigationController, delegate: self)
        childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }
}

// MARK: AddMangasCoordinatorDelegate
extension AppCoordinator: AddMangasCoordinatorDelegate {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator) {
        childCoordinators.removeLast()
        let mangas = loadMangas()
        libraryView?.mangas = mangas
    }

    func cancel(_ addMangasCoordinator: AddMangasCoordinator) {
        childCoordinators.removeLast()
    }
}

extension AppCoordinator: ViewMangaCoordinatorDelegate {
    func didEnd(viewMangaCoordinator: ViewMangaCoordinator) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator is ViewMangaCoordinator {
            childCoordinators.remove(at: index)
        }
    }
}
