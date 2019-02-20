//
//  AppCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import CoreData

class AppCoordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Any]()
    
    init(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    func start() {
        let library = LibraryViewController()
        library.delegate = self
        library.mangas = self.loadMangas()
        self.navigationController.pushViewController(library, animated: false)
    }
    
    func loadMangas() -> [Manga] {
        return CoreDataManager.sharedManager.fetchAllMangas() ?? [Manga]()
    }
}

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectAdd(_ libraryViewController: LibraryViewController) {
        let addMangasCoordinator = AddMangasCoordinator(navigation: self.navigationController)
        addMangasCoordinator.delegate = self
        self.childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }
}

// MARK: AddMangasCoordinatorDelegate
extension AppCoordinator: AddMangasCoordinatorDelegate {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator) {
        self.childCoordinators.removeLast()
    }
}
