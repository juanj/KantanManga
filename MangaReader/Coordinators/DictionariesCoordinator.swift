//
//  DictionariesCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import UIKit

class DictionariesCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private var dictionariesViewController: DictionariesViewController?

    private let dictionaryDecoder: DictionaryDecoder
    private let navigationController: Navigable
    private let compoundDictionary: CompoundDictionary
    init(navigation: Navigable, compoundDictionary: CompoundDictionary = CompoundDictionary(), dictionaryDecoder: DictionaryDecoder = YomichanDictionaryDecoder()) {
        navigationController = navigation
        self.compoundDictionary = compoundDictionary
        self.dictionaryDecoder = dictionaryDecoder
    }

    func start() {
        if !compoundDictionary.isConnected {
            try? compoundDictionary.connectToDataBase()
        }
        let dictionaries = (try? compoundDictionary.getDictionaries()) ?? []
        let dictionariesViewController = DictionariesViewController(dictionaries: dictionaries, delegate: self)
        navigationController.pushViewController(dictionariesViewController, animated: true)
        self.dictionariesViewController = dictionariesViewController
    }

    private func refreshDictionaries() {
        let dictionaries = (try? compoundDictionary.getDictionaries()) ?? []
        dictionariesViewController?.setDictionaries(dictionaries)
    }
}

extension DictionariesCoordinator: DictionariesViewControllerDelegate {
    func didSelectAdd(_ dictionariesViewController: DictionariesViewController) {
        let filesView = UIDocumentPickerViewController(documentTypes: ["public.zip-archive"], in: .import)
        filesView.allowsMultipleSelection = false
        filesView.title = "Select dictionary file"
        filesView.delegate = self
        navigationController.present(filesView, animated: true, completion: nil)
    }
}

extension DictionariesCoordinator: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else { return }

        if !compoundDictionary.isConnected {
            try? compoundDictionary.createDataBase()
            try? compoundDictionary.connectToDataBase()
        }

        dictionariesViewController?.startLoading()
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let decodedDictionary = try self.dictionaryDecoder.decodeDictionary(path: fileUrl, progress: { progress in
                    DispatchQueue.main.async {
                        self.dictionariesViewController?.progressView.setProgress(progress * 0.5, animated: true)
                    }
                })
                try self.compoundDictionary.addDictionary(decodedDictionary, progress: { progress in
                    DispatchQueue.main.async {
                        self.dictionariesViewController?.progressView.setProgress(0.5 + progress * 0.5, animated: true)
                    }
                })
                DispatchQueue.main.async {
                    self.dictionariesViewController?.endLoading()
                    self.refreshDictionaries()
                }
            } catch let error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.dictionariesViewController?.endLoading()
                }
            }
        }
    }
}
