//
//  SettingsCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 27/06/20.
//

import Foundation
import SwiftUI

protocol SettingsCoordinatorDelegate: AnyObject {
    func didEnd(_ settingsCoordinator: SettingsCoordinator)
}

class SettingsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private let navigation: Navigable
    private let coreDataManager: CoreDataManageable
    private weak var delegate: SettingsCoordinatorDelegate?
    private let presentedNavigationController = UINavigationController()
    init(navigation: Navigable, coreDataManager: CoreDataManageable, delegate: SettingsCoordinatorDelegate) {
        self.navigation = navigation
        self.coreDataManager = coreDataManager
        self.delegate = delegate
    }

    func start() {
        let settingsView = SettingsTableViewController(delegate: self)
        presentedNavigationController.setViewControllers([settingsView], animated: false)
        navigation.present(presentedNavigationController, animated: true, completion: nil)
    }
}

// MARK: SettingsTableViewControllerDelegate
extension SettingsCoordinator: SettingsTableViewControllerDelegate {
    func didSelectAbout(_ settingsTableViewController: SettingsTableViewController) {
        let hostingView = UIHostingController(rootView: AboutView())
        hostingView.title = "About"
        presentedNavigationController.pushViewController(hostingView, animated: true)
    }

    func didSelectLoadDemo(_ settingsTableViewController: SettingsTableViewController) {
        settingsTableViewController.startLoading()
        coreDataManager.createDemoManga {
            DispatchQueue.main.async {
                settingsTableViewController.endLoading()
                self.navigation.dismiss(animated: true, completion: nil)
                self.delegate?.didEnd(self)
            }
        }
    }

    func didSelectAcknowledgments(_ settingsTableViewController: SettingsTableViewController) {
        let hostingView = UIHostingController(rootView: AcknowledgmentsView())
        hostingView.title = "Acknowledgments"
        presentedNavigationController.pushViewController(hostingView, animated: true)
    }

    func didSelectClose(_ settingsTableViewController: SettingsTableViewController) {
        navigation.dismiss(animated: true, completion: nil)
    }

    func didSelectDictionaries(_ settingsTableViewController: SettingsTableViewController) {
        let dictionariesCoordinator = DictionariesCoordinator(navigation: presentedNavigationController)
        childCoordinators.append(dictionariesCoordinator)
        dictionariesCoordinator.start()
    }

    func didSelectResetDictionaries(_ settingsTableViewController: SettingsTableViewController) {
        let alert = UIAlertController(title: "Are you sure?", message: "This will delete all imported dictionaries and reset the dictionaries database to its initial state. This may help if the database has become damaged.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            guard let dictUrl = Bundle.main.url(forResource: "dic", withExtension: "db") else { return }
            settingsTableViewController.startLoading()
            DatabaseUtils.resetToInitialDatabase(initialPath: dictUrl) {
                DispatchQueue.main.async {
                    settingsTableViewController.endLoading()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        settingsTableViewController.present(alert, animated: true, completion: nil)
    }

    func didSelectFAQ(_ settingsTableViewController: SettingsTableViewController) {
        presentedNavigationController.pushViewController(FAQViewController(), animated: true)
    }
}
