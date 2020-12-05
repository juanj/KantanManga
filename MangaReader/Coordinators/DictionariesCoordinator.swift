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
    init(navigation: Navigable) {
        navigationController = navigation
    }

    func start() {
        navigationController.pushViewController(DictionariesViewController(), animated: true)
    }
}
