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
    
    init(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    func start() {
        let library = LibraryViewController()
        library.mangas = self.loadMangas()
        self.navigationController.pushViewController(library, animated: false)
    }
    
    func loadMangas() -> [Manga] {
        return CoreDataManager.sharedManager.fetchAllMangass() ?? [Manga]()
    }
}
