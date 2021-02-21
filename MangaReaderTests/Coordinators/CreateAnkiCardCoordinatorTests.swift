//
//  CreateAnkiCardCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga
import XCTest

class CreateAnkiCardCoordinatorTests: XCTestCase {
    func testStart_withNoPresentedView_presentsNavigable() {
        let mockNavigation = FakeNavigation()
        let createAnkiCardCoordinator = TestsFactories.createCreateAnkiCardCoordinator(navigable: mockNavigation)

        createAnkiCardCoordinator.start()

        XCTAssertNotNil(mockNavigation.presentedViewController as? Navigable)
    }

    func testStart_withNoPresentedView_setsRootViewControllerCreateAnkiViewController() {
        let presentedMockNavigation = FakeNavigation()
        let createAnkiCardCoordinator = TestsFactories.createTestableCreateAnkiCardCoordinator()

        createAnkiCardCoordinator.presentableNavigable = presentedMockNavigation
        createAnkiCardCoordinator.start()

        XCTAssertNotNil(presentedMockNavigation.viewControllers.first as? CreateAnkiCardViewController)
    }

    func testCancel_withDelegate_callsDidEnd() {
        let mockDelegate = FakeCreateAnkiCardCoordinatorDelegate()
        let createAnkiCardCoordinator = TestsFactories.createCreateAnkiCardCoordinator(delegate: mockDelegate)

        createAnkiCardCoordinator.start()
        createAnkiCardCoordinator.cancel(TestsFactories.createCreateAnkiCardViewController())

        XCTAssertTrue(mockDelegate.didEndCalled)
    }

    func testCancel_withPresentedNavigation_dismissNavigation() {
        let mockNavigation = FakeNavigation()
        let createAnkiCardCoordinator = TestsFactories.createCreateAnkiCardCoordinator(navigable: mockNavigation)

        mockNavigation.present(UIViewController(), animated: false)
        createAnkiCardCoordinator.cancel(TestsFactories.createCreateAnkiCardViewController())

        XCTAssertNil(mockNavigation.presentedViewController)
    }

    func testSave_withInMemoryCoreData_createsAnkiCard() {
        let inMemoryCoreData = InMemoryCoreDataManager()
        let createAnkiCardCoordinator = TestsFactories.createCreateAnkiCardCoordinator(coreDataManager: inMemoryCoreData)

        createAnkiCardCoordinator.save(TestsFactories.createCreateAnkiCardViewController(), sentence: "Test", definition: "Definition")

        XCTAssertEqual(inMemoryCoreData.fetchAllAnkiCards()?.count, 1)
    }
}
