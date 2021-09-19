//
//  SentencesCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 21/02/21.
//

import Foundation

class SentencesCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private var selectedSentence: Sentence?
    private var sentencesViewController: SentencesViewController?

    private var navigation: Navigable
    private var coreDataManager: CoreDataManageable
    private var ankiConfigManager: AnkiConfigManager
    init(navigation: Navigable, coreDataManager: CoreDataManageable, ankiConfigManager: AnkiConfigManager) {
        self.navigation = navigation
        self.coreDataManager = coreDataManager
        self.ankiConfigManager = ankiConfigManager
    }

    func start() {
        let sentencesViewController = SentencesViewController(sentences: coreDataManager.fetchAllSentences() ?? [], delegate: self)
        navigation.setViewControllers([sentencesViewController], animated: false)
        self.sentencesViewController = sentencesViewController
    }
}

extension SentencesCoordinator: SentencesViewControllerDelegate {
    func refresh(_ sentencesViewController: SentencesViewController) {
        sentencesViewController.sentences = coreDataManager.fetchAllSentences() ?? []
    }

    func didSelectSentence(_ sentencesViewController: SentencesViewController, sentence: Sentence) {
        selectedSentence = sentence
        let editSentenceCoordinator = EditSentenceCoordinator(navigation: navigation, sentence: sentence, delegate: self)
        childCoordinators.append(editSentenceCoordinator)
        editSentenceCoordinator.start()
    }

    func didSelectSyncSentences(_ sentencesViewController: SentencesViewController) {
        if let config = ankiConfigManager.savedConfig() {
            // TODO: Sync sentences
        } else {
            let configureAnkiCoordinator = ConfigureAnkiCoordinator(
                navigation: navigation,
                ankiConfigManager: ankiConfigManager,
                delegate: self
            )
            childCoordinators.append(configureAnkiCoordinator)
            configureAnkiCoordinator.start()
        }
    }
}

extension SentencesCoordinator: EditSentenceCoordinatorDelegate {
    func didSelectDelete(_ createSentenceCoordinator: EditSentenceCoordinator) {
        removeChildCoordinator(type: EditSentenceCoordinator.self)
        guard let selectedSentence = selectedSentence else { return }
        coreDataManager.delete(sentence: selectedSentence)
        sentencesViewController?.sentences = coreDataManager.fetchAllSentences() ?? []
    }

    func didCancel(_ createSentenceCoordinator: EditSentenceCoordinator) {
        removeChildCoordinator(type: EditSentenceCoordinator.self)
    }

    func didEnd(_ createSentenceCoordinator: EditSentenceCoordinator, image: UIImage?, sentence: String, definition: String) {
        removeChildCoordinator(type: EditSentenceCoordinator.self)
        guard let selectedSentence = selectedSentence else { return }
        selectedSentence.imageData = image?.jpegData(compressionQuality: 1)
        selectedSentence.sentence = sentence
        selectedSentence.definition = definition
        coreDataManager.update(sentence: selectedSentence)

        coreDataManager.refreshAll()
        sentencesViewController?.refresh()
    }
}

extension SentencesCoordinator: ConfigureAnkiCoordinatorDelegate {
    func didEnd(_ configureAnkiCoordinator: ConfigureAnkiCoordinator) {
        removeChildCoordinator(type: ConfigureAnkiCoordinator.self)
    }
}
