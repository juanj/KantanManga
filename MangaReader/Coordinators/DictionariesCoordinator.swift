//
//  DictionariesCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import UIKit

class DictionariesCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private let navigationController: Navigable
    private let compoundDictionary: CompoundDictionary
    init(navigation: Navigable, compoundDictionary: CompoundDictionary = CompoundDictionary()) {
        navigationController = navigation
        self.compoundDictionary = compoundDictionary
    }

    func start() {
        if !compoundDictionary.isConnected {
            try? compoundDictionary.connectToDataBase()
        }
        let dictionaries = (try? compoundDictionary.getDictionaries()) ?? []
        navigationController.pushViewController(DictionariesViewController(dictionaries: dictionaries), animated: true)
    }
}
