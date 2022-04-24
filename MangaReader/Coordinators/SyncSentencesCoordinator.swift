//
//  SyncSentencesCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 19/09/21.
//

import Foundation

protocol SyncSentencesCoordinatorDelegate: AnyObject {
    func didEnd(_ syncSentencesCoordinator: SyncSentencesCoordinator)
}

class SyncSentencesCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private lazy var presentedNavigationController = createPresentableNavigation()
    private var transferringSentencesViewController: TransferringSentencesViewController?
    private let operationQueue = OperationQueue()
    private var syncedSentences = [Sentence]()
    private var failedSentences = [Sentence]()
    private var progress = 0 {
        didSet {
            DispatchQueue.main.async {
                self.transferringSentencesViewController?.progress = self.progress
            }
        }
    }

    private var report = "" {
        didSet {
            transferringSentencesViewController?.updateReport(report: report)
        }
    }

    private let navigation: Navigable
    private let ankiConfig: AnkiConfig
    private let ankiConnectManager: AnkiConnectManager
    private let sentences: [Sentence]
    private var coreDataManager: CoreDataManageable
    private weak var delegate: SyncSentencesCoordinatorDelegate?
    init(
        navigation: Navigable,
        ankiConfig: AnkiConfig,
        ankiConnectManager: AnkiConnectManager,
        sentences: [Sentence],
        coreDataManager: CoreDataManageable,
        delegate: SyncSentencesCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.ankiConfig = ankiConfig
        self.ankiConnectManager = ankiConnectManager
        self.sentences = sentences
        self.coreDataManager = coreDataManager
        self.delegate = delegate
        operationQueue.maxConcurrentOperationCount = 1
    }

    func start() {
        let transferringSentencesViewController = TransferringSentencesViewController(total: sentences.count, delegate: self)
        presentedNavigationController.setViewControllers([transferringSentencesViewController], animated: false)
        navigation.present(presentedNavigationController, animated: true, completion: nil)

        self.transferringSentencesViewController = transferringSentencesViewController

        startSyncing()
    }

    func createPresentableNavigation() -> Navigable {
        return UINavigationController()
    }

    private func startSyncing() {
        for sentence in sentences {
            let operation = AnkiSyncCardOperation(
                sentence: sentence,
                config: ankiConfig,
                manager: ankiConnectManager
            )
            operation.completionBlock = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    if let error = operation.error {
                        self?.report += "\(sentence.sentence) • failed with error: \(error.localizedDescription)\n"
                        self?.failedSentences.append(sentence)
                    } else if let noteId = operation.noteId {
                        self?.report += "\(sentence.sentence) • was successfully added to Anki. Note id: \(noteId)\n"
                        self?.syncedSentences.append(sentence)
                    } else {
                        self?.report += "\(sentence.sentence) • did not failed with an error but the note id is not available\n"
                        self?.failedSentences.append(sentence)
                    }
                    self?.progress += 1
                }
            }
            operationQueue.addOperation(operation)
        }
    }
}

extension SyncSentencesCoordinator: TransferringSentencesViewControllerDelegate {
    func didSelectClose(_ transferringSentencesViewController: TransferringSentencesViewController) {
        operationQueue.cancelAllOperations()
        navigation.dismiss(animated: true, completion: nil)
    }

    func didSelectDone(_ transferringSentencesViewController: TransferringSentencesViewController) {
        let alert = UIAlertController(
            title: "Delete sentences?",
            message: "\(syncedSentences.count) sentences were successfully added to Anki and \(failedSentences.count) failed. Do you want to remove successfully added sentences from the app?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.syncedSentences.forEach { self.coreDataManager.delete(sentence: $0) }
            self.navigation.dismiss(animated: true) {
                self.delegate?.didEnd(self)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            self.navigation.dismiss(animated: true) {
                self.delegate?.didEnd(self)
            }
        }))

        presentedNavigationController.present(alert, animated: true, completion: nil)
    }
}
