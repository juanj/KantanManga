//
//  AppCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 21/02/21.
//

import Foundation

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private let tabBarControler = UITabBarController()

    private var navigation: Navigable
    private var coreDataManager: CoreDataManageable
    init(navigation: Navigable, coreDataManager: CoreDataManageable) {
        self.navigation = navigation
        self.coreDataManager = coreDataManager
    }

    func start() {
        let libraryNavigation = createLibraryNavigation()
        let sentencesNavigation = createSentencesNavigation()

        let libraryCoordinator = LibraryCoordinator(navigation: libraryNavigation, coreDataManager: coreDataManager)
        let sentencesCoordinator = SentencesCoordinator(navigation: sentencesNavigation, coreDataManager: coreDataManager, ankiConfigManager: AnkiConfigManager())

        childCoordinators.append(libraryCoordinator)
        childCoordinators.append(sentencesCoordinator)

        tabBarControler.setViewControllers([libraryNavigation, sentencesNavigation], animated: false)
        navigation.setViewControllers([tabBarControler], animated: false)

        libraryCoordinator.start()
        sentencesCoordinator.start()
    }

    func createLibraryNavigation() -> Navigable {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "book.fill"), selectedImage: nil)
        return navigationController
    }

    func createSentencesNavigation() -> Navigable {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Sentences", image: UIImage(systemName: "text.bubble.fill"), selectedImage: nil)
        return navigationController
    }
}
