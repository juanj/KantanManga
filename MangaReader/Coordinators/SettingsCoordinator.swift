//
//  SettingsCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 27/06/20.
//

import Foundation
import SwiftUI

class SettingsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private let navigationController: UINavigationController
    private let presentedNavigationController = UINavigationController()
    init(navigation: UINavigationController) {
        navigationController = navigation
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
}
