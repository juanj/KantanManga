//
//  CreateSentenceCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga
import XCTest

class CreateSentenceCoordinatorTests: XCTestCase {
    func testStart_withNoPresentedView_presentsNavigable() {
        let mockNavigation = FakeNavigation()
        let createSentenceCoordinator = TestsFactories.createEditSentenceCoordinator(navigable: mockNavigation)

        createSentenceCoordinator.start()

        XCTAssertNotNil(mockNavigation.presentedViewController as? Navigable)
    }

    func testStart_withNoPresentedView_setsRootViewControllerCreateSentenceViewController() {
        let presentedMockNavigation = FakeNavigation()
        let createSentenceCoordinator = TestsFactories.createTestableEditSentenceCoordinator()

        createSentenceCoordinator.presentableNavigable = presentedMockNavigation
        createSentenceCoordinator.start()

        XCTAssertNotNil(presentedMockNavigation.viewControllers.first as? CreateSentenceViewController)
    }

    func testCancel_withDelegate_callsDidCancel() {
        let mockDelegate = FakeEditSentenceCoordinatorDelegate()
        let createSentenceCoordinator = TestsFactories.createEditSentenceCoordinator(delegate: mockDelegate)

        createSentenceCoordinator.start()
        createSentenceCoordinator.cancel(TestsFactories.createCreateSentenceViewController())

        XCTAssertTrue(mockDelegate.didCancelCalled)
    }

    func testCancel_withPresentedNavigation_dismissNavigation() {
        let mockNavigation = FakeNavigation()
        let createSentenceCoordinator = TestsFactories.createEditSentenceCoordinator(navigable: mockNavigation)

        mockNavigation.present(UIViewController(), animated: false)
        createSentenceCoordinator.cancel(TestsFactories.createCreateSentenceViewController())

        XCTAssertNil(mockNavigation.presentedViewController)
    }
}
