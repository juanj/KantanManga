//
//  DictionariesCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import UIKit

class DictionariesCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private let importer: DictionaryImporter
    private let navigationController: Navigable
    private let compoundDictionary: CompoundDictionary
    init(navigation: Navigable, compoundDictionary: CompoundDictionary = CompoundDictionary(), importer: DictionaryImporter = YomichanDictionaryImporter()) {
        navigationController = navigation
        self.compoundDictionary = compoundDictionary
        self.importer = importer
    }

    func start() {
        if !compoundDictionary.isConnected {
            try? compoundDictionary.connectToDataBase()
        }
        let dictionaries = (try? compoundDictionary.getDictionaries()) ?? []
        navigationController.pushViewController(DictionariesViewController(dictionaries: dictionaries, delegate: self), animated: true)
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

        do {
            try importer.importDictionary(path: fileUrl, to: compoundDictionary)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
