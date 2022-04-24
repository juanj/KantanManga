//
//  ConfigureAnkiCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import Foundation

protocol ConfigureAnkiCoordinatorDelegate: AnyObject {
    func didEnd(_ configureAnkiCoordinator: ConfigureAnkiCoordinator)
}

class ConfigureAnkiCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private var presentedNavigation: Navigable!
    private var ankiConnectManager: AnkiConnectManager?
    private var localNetworkAuthorization: LocalNetworkAuthorization?

    private var host: String?
    private var key: String?
    private var deck: String?
    private var model: String?
    private var wordField: String?
    private var readingField: String?
    private var sentenceField: String?
    private var definitionField: String?
    private var imageField: String?

    private var namesCompletion: ((String) -> Void)?

    private let navigation: Navigable
    private let ankiConfigManager: AnkiConfigManager
    private weak var delegate: ConfigureAnkiCoordinatorDelegate?
    init(navigation: Navigable, ankiConfigManager: AnkiConfigManager, delegate: ConfigureAnkiCoordinatorDelegate) {
        self.navigation = navigation
        self.ankiConfigManager = ankiConfigManager
        self.delegate = delegate
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

    private func getAndShowFields(
        ankiSettingsViewController: AnkiSettingsViewController,
        title: String,
        completion: @escaping (String) -> Void
    ) {
        guard let model = model, !model.isEmpty else {
            showError(message: "You need to select a note type first")
            return
        }

        ankiSettingsViewController.startLoading()
        ankiConnectManager?.getModelFields(model) { [weak self] result in
            switch result {
            case let .success(decks):
                self?.showNamesList(names: decks, title: title, completion: completion)
            case let .failure(error):
                self?.showError(message: error.localizedDescription)
            }
            ankiSettingsViewController.endLoading()
        }
    }
}

extension ConfigureAnkiCoordinator: AnkiConnectionViewControllerDelegate {
    func didSelectSave(_ ankiConnectionViewController: AnkiConnectionViewController, host: String, key: String?) {
        localNetworkAuthorization = LocalNetworkAuthorization()
        localNetworkAuthorization?.requestAuthorization { [weak self] _ in
            // TODO: Handle local network access rejected
            self?.localNetworkAuthorization = nil
            self?.saveHostAndKey(ankiConnectionViewController, host: host, key: key)
        }
    }

    private func saveHostAndKey(_ ankiConnectionViewController: AnkiConnectionViewController, host: String, key: String?) {
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
                self?.host = host
                self?.key = key
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

    func didSelectWordField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        getAndShowFields(ankiSettingsViewController: ankiSettingsViewController, title: "Word Field") { [weak self] field in
            self?.wordField = field
            ankiSettingsViewController.setWordField(field)
            self?.presentedNavigation.popViewController(animated: true)
        }
    }

    func didSelectReadingField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        getAndShowFields(ankiSettingsViewController: ankiSettingsViewController, title: "Reading Field") { [weak self] field in
            self?.readingField = field
            ankiSettingsViewController.setReadingField(field)
            self?.presentedNavigation.popViewController(animated: true)
        }
    }

    func didSelectSentenceField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        getAndShowFields(ankiSettingsViewController: ankiSettingsViewController, title: "Sentence Field") { [weak self] field in
            self?.sentenceField = field
            ankiSettingsViewController.setSentenceField(field)
            self?.presentedNavigation.popViewController(animated: true)
        }
    }

    func didSelectDefinitionField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        getAndShowFields(ankiSettingsViewController: ankiSettingsViewController, title: "Definition Field") { [weak self] field in
            self?.definitionField = field
            ankiSettingsViewController.setDefinitionField(field)
            self?.presentedNavigation.popViewController(animated: true)
        }
    }

    func didSelectImageField(_ ankiSettingsViewController: AnkiSettingsViewController) {
        getAndShowFields(ankiSettingsViewController: ankiSettingsViewController, title: "Image Field") { [weak self] field in
            self?.imageField = field
            ankiSettingsViewController.setImageField(field)
            self?.presentedNavigation.popViewController(animated: true)
        }
    }

    func didSelectSave(_ ankiSettingsViewController: AnkiSettingsViewController) {
        guard let host = host,
              let deck = deck,
              let model = model
        else { return }

        guard wordField != nil ||
                readingField != nil ||
                sentenceField != nil ||
                definitionField != nil ||
                imageField != nil
        else { return }

        ankiConfigManager.saveConfig(
            AnkiConfig(
                address: host,
                key: key,
                deck: deck,
                note: model,
                wordField: wordField,
                readingField: readingField,
                sentenceField: sentenceField,
                definitionField: definitionField,
                imageField: imageField
            )
        )

        navigation.dismiss(animated: true) {
            self.delegate?.didEnd(self)
        }
    }
}

extension ConfigureAnkiCoordinator: AnkiNamesListViewControllerDelegate {
    func didSelectName(_ ankiNamesListViewController: AnkiNamesListViewController, name: String) {
        namesCompletion?(name)
        namesCompletion = nil
    }
}
