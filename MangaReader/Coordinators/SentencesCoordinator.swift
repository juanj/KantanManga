//
//  SentencesCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 21/02/21.
//

import Foundation

class SentencesCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private var navigation: Navigable
    private var coreDataManager: CoreDataManageable
    init(navigation: Navigable, coreDataManager: CoreDataManageable) {
        self.navigation = navigation
        self.coreDataManager = coreDataManager
    }

    func start() {
        navigation.setViewControllers([SentencesViewController(sentences: coreDataManager.fetchAllSentences() ?? [], delegate: self)], animated: false)
    }
}

extension SentencesCoordinator: SentencesViewControllerDelegate {
    func refresh(_ sentencesViewController: SentencesViewController) {
        sentencesViewController.sentences = coreDataManager.fetchAllSentences() ?? []
    }
}
