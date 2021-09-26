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

    private var transferringSentencesViewController: TransferringSentencesViewController?
    private let operationQueue = OperationQueue()
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
    private weak var delegate: SyncSentencesCoordinatorDelegate?
    init(
        navigation: Navigable,
        ankiConfig: AnkiConfig,
        ankiConnectManager: AnkiConnectManager,
        sentences: [Sentence],
        delegate: SyncSentencesCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.ankiConfig = ankiConfig
        self.ankiConnectManager = ankiConnectManager
        self.sentences = sentences
        self.delegate = delegate
        operationQueue.maxConcurrentOperationCount = 1
    }

    func start() {
        let transferringSentencesViewController = TransferringSentencesViewController(total: sentences.count)
        navigation.present(transferringSentencesViewController, animated: true, completion: nil)

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
                    } else if let noteId = operation.noteId {
                        self?.report += "\(sentence.sentence) • was successfully added to Anki. Note id: \(noteId)\n"
                    } else {
                        self?.report += "\(sentence.sentence) • did not failed with an error but the note id is not available\n"
                    }
                    self?.progress += 1
                }
            }
            operationQueue.addOperation(operation)
        }
    }
}
