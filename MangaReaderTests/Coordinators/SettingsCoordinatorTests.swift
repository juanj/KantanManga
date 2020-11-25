//
//  SettingsCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 25/11/20.
//

import XCTest
@testable import Kantan_Manga

class SettingsCoordinatorTests: XCTestCase {

    // MARK: SettingsTableViewControllerDelegate
    func testSettingsTableViewControllerDelegateDidSelectClose_withPresentedViewController_dismissViewController() {
        let mockNavigation = FakeNavigation()
        let settingsCoordinator = TestsFactories.createSettingsCoordinator(navigable: mockNavigation)

        mockNavigation.present(UIViewController(), animated: false)
        settingsCoordinator.didSelectClose(SettingsTableViewController(delegate: FakeSettingsTableViewControllerDelegate()))

        XCTAssertNil(mockNavigation.presentedViewController)
    }
}
