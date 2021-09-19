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
    private var progress = 0 {
        didSet {
            DispatchQueue.main.async {
                self.transferringSentencesViewController?.setProgress(current: self.progress, total: self.sentences.count)
            }
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
    }

    func start() {
        let transferringSentencesViewController = TransferringSentencesViewController()
        navigation.present(transferringSentencesViewController, animated: true, completion: nil)

        self.transferringSentencesViewController = transferringSentencesViewController

        startSyncing()
    }

    func createPresentableNavigation() -> Navigable {
        return UINavigationController()
    }

    private func startSyncing() {
        let group = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "SentencesTransferQueue")

        dispatchQueue.async {
            for sentence in self.sentences {
                let fields = [
                    self.ankiConfig.sentenceField: sentence.sentence,
                    self.ankiConfig.definitionField: self.addAnkiNewLines(to: sentence.definition)
                ]

                var picture: CreateNoteRequest.Picture?
                if let imageData = sentence.imageData, let imageField = self.ankiConfig.imageField {
                    picture = CreateNoteRequest.Picture(
                        filename: "\(sentence.sentence).png",
                        data: imageData.base64EncodedString(),
                        fields: [imageField]
                    )
                }
                group.enter()
                self.ankiConnectManager.addNoteWith(
                    model: self.ankiConfig.note,
                    deck: self.ankiConfig.deck,
                    fields: fields,
                    picture: picture
                ) { [weak self] result in
                    print(result)
                    self?.progress += 1
                    group.leave()
                }
                group.wait()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.navigation.dismiss(animated: true) {
                self.delegate?.didEnd(self)
            }
        }
    }

    private func addAnkiNewLines(to string: String) -> String {
        return string.replacingOccurrences(of: "\n", with: "</br>")
    }
}
