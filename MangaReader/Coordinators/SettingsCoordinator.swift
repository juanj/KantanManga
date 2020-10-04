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

    private let navigationController: UINavigationController
    private weak var delegate: SettingsCoordinatorDelegate?
    private let presentedNavigationController = UINavigationController()
    init(navigation: UINavigationController, delegate: SettingsCoordinatorDelegate) {
        navigationController = navigation
        self.delegate = delegate
    }

    func start() {
        let settingsView = SettingsTableViewController(delegate: self)
        presentedNavigationController.setViewControllers([settingsView], animated: false)
        navigationController.present(presentedNavigationController, animated: true, completion: nil)
    }
}

extension SettingsCoordinator: SettingsTableViewControllerDelegate {
    func didSelectAbout(_ settingsTableViewController: SettingsTableViewController) {
        let hostingView = UIHostingController(rootView: AboutView())
        hostingView.title = "About"
        presentedNavigationController.pushViewController(hostingView, animated: true)
    }

    func didSelectLoadDemo(_ settingsTableViewController: SettingsTableViewController) {
        settingsTableViewController.startLoading()
        CoreDataManager.sharedManager.createDemoManga {
            DispatchQueue.main.async {
                settingsTableViewController.endLoading()
                self.navigationController.dismiss(animated: true, completion: nil)
                self.delegate?.didEnd(self)
            }
        }
    }

    func didSelectAcknowledgments(_ settingsTableViewController: SettingsTableViewController) {
        let hostingView = UIHostingController(rootView: AcknowledgmentsView())
        hostingView.title = "Acknowledgments"
        presentedNavigationController.pushViewController(hostingView, animated: true)
    }
}
