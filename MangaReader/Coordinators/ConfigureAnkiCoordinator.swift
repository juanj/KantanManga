//
//  ConfigureAnkiCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

class ConfigureAnkiCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private var presentedNavigation: Navigable!
    private var ankiConnectManager: AnkiConnectManager?

    private var navigation: Navigable
    init(navigation: Navigable) {
        self.navigation = navigation
    }

    func start() {
        let ankiConnectionViewController = AnkiConnectionViewController(delegate: self)
        presentedNavigation = createPresentableNavigation()
        presentedNavigation.setViewControllers([ankiConnectionViewController], animated: false)
        navigation.present(presentedNavigation, animated: true, completion: nil)
    }

    func createPresentableNavigation() -> Navigable {
        return UINavigationController()
    }

    private func showError(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.presentedNavigation.present(alert, animated: true, completion: nil)
    }
}

extension ConfigureAnkiCoordinator: AnkiConnectionViewControllerDelegate {
    func didSelectSave(_ ankiConnectionViewController: AnkiConnectionViewController, host: String, key: String?) {
        let url = "http://\(host)"
        guard let url = URL(string: url) else {
            showError(message: "Invalid host")
            return
        }

        ankiConnectManager = AnkiConnectManager(url: url, key: key)

        ankiConnectionViewController.view.endEditing(true)
        ankiConnectionViewController.startLoading()

        ankiConnectManager?.checkConnection { [weak self] result in
            switch result {
            case .success:
                self?.showError(message: "Success")
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiConnectionViewController.endLoading()
        }
    }
}
