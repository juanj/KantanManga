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

    private var deck: String?
    private var model: String?
    private var sentenceField: String?
    private var definitionField: String?
    private var imageField: String?

    private var namesCompletion: ((String) -> Void)?

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

    private func showAnkiSettings() {
        let ankiSettingsViewController = AnkiSettingsViewController(delegate: self)
        presentedNavigation.pushViewController(ankiSettingsViewController, animated: true)
    }

    func showNamesList(names: [String], title: String, completion: @escaping (String) -> Void) {
        namesCompletion = completion
        let ankiNamesListViewController = AnkiNamesListViewController(names: names, title: title, delegate: self)
        presentedNavigation.pushViewController(ankiNamesListViewController, animated: true)
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
                self?.showAnkiSettings()
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiConnectionViewController.endLoading()
        }
    }
}

extension ConfigureAnkiCoordinator: AnkiSettingsViewControllerDelegate {
    func didSelectDeck(_ ankiSettingsViewController: AnkiSettingsViewController) {
        ankiSettingsViewController.startLoading()

        ankiConnectManager?.getDeckNames { [weak self] result in
            switch result {
            case let .success(decks):
                self?.showNamesList(names: decks, title: "Decks", completion: { deck in
                    self?.deck = deck
                    ankiSettingsViewController.setDeck(deck)
                    self?.presentedNavigation.popViewController(animated: true)
                })
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiSettingsViewController.endLoading()
        }
    }

    func didSelectNoteType(_ ankiSettingsViewController: AnkiSettingsViewController) {
        ankiSettingsViewController.startLoading()

        ankiConnectManager?.getModelNames { [weak self] result in
            switch result {
            case let .success(models):
                self?.showNamesList(names: models, title: "Note Types", completion: { model in
                    self?.model = model
                    ankiSettingsViewController.setNoteType(model)
                    self?.presentedNavigation.popViewController(animated: true)
                })
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiSettingsViewController.endLoading()
        }
    }

    func didSelectSentenceField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        guard let model = model, !model.isEmpty else {
            showError(message: "You need to select a note type first")
            return
        }
        ankiSettingsViewController.startLoading()

        ankiConnectManager?.getModelFields(model) { [weak self] result in
            switch result {
            case let .success(fields):
                self?.showNamesList(names: fields, title: "Fields", completion: { field in
                    self?.sentenceField = field
                    ankiSettingsViewController.setSentenceField(field)
                    self?.presentedNavigation.popViewController(animated: true)
                })
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiSettingsViewController.endLoading()
        }
    }

    func didSelectDefinitionField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        guard let model = model, !model.isEmpty else {
            showError(message: "You need to select a note type first")
            return
        }
        ankiSettingsViewController.startLoading()

        ankiConnectManager?.getModelFields(model) { [weak self] result in
            switch result {
            case let .success(fields):
                self?.showNamesList(names: fields, title: "Fields", completion: { field in
                    self?.definitionField = field
                    ankiSettingsViewController.setDefinitionField(field)
                    self?.presentedNavigation.popViewController(animated: true)
                })
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiSettingsViewController.endLoading()
        }
    }

    func didSelectImageField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        guard let model = model, !model.isEmpty else {
            showError(message: "You need to select a note type first")
            return
        }
        ankiSettingsViewController.startLoading()

        ankiConnectManager?.getModelFields(model) { [weak self] result in
            switch result {
            case let .success(fields):
                self?.showNamesList(names: fields, title: "Fields", completion: { field in
                    self?.imageField = field
                    ankiSettingsViewController.setImageField(field)
                    self?.presentedNavigation.popViewController(animated: true)
                })
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiSettingsViewController.endLoading()
        }
    }

    func didSelectSave(_ ankiSettingsViewController: AnkiSettingsViewController) {

    }
}

extension ConfigureAnkiCoordinator: AnkiNamesListViewControllerDelegate {
    func didSelectName(_ ankiNamesListViewController: AnkiNamesListViewController, name: String) {
        namesCompletion?(name)
        namesCompletion = nil
    }
}
