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
        let createSentenceCoordinator = TestsFactories.createCreateSentenceCoordinator(navigable: mockNavigation)

        createSentenceCoordinator.start()

        XCTAssertNotNil(mockNavigation.presentedViewController as? Navigable)
    }

    func testStart_withNoPresentedView_setsRootViewControllerCreateAnkiViewController() {
        let presentedMockNavigation = FakeNavigation()
        let createSentenceCoordinator = TestsFactories.createTestableCreateSentenceCoordinator()

        createSentenceCoordinator.presentableNavigable = presentedMockNavigation
        createSentenceCoordinator.start()

        XCTAssertNotNil(presentedMockNavigation.viewControllers.first as? CreateSentenceViewController)
    }

    func testCancel_withDelegate_callsDidEnd() {
        let mockDelegate = FakeCreateSentenceCoordinatorDelegate()
        let createSentenceCoordinator = TestsFactories.createCreateSentenceCoordinator(delegate: mockDelegate)

        createSentenceCoordinator.start()
        createSentenceCoordinator.cancel(TestsFactories.createCreateSentenceViewController())

        XCTAssertTrue(mockDelegate.didEndCalled)
    }

    func testCancel_withPresentedNavigation_dismissNavigation() {
        let mockNavigation = FakeNavigation()
        let createSentenceCoordinator = TestsFactories.createCreateSentenceCoordinator(navigable: mockNavigation)

        mockNavigation.present(UIViewController(), animated: false)
        createSentenceCoordinator.cancel(TestsFactories.createCreateSentenceViewController())

        XCTAssertNil(mockNavigation.presentedViewController)
    }

    func testSave_withInMemoryCoreData_createsSentence() {
        let inMemoryCoreData = InMemoryCoreDataManager()
        let createSentenceCoordinator = TestsFactories.createCreateSentenceCoordinator(coreDataManager: inMemoryCoreData)

        createSentenceCoordinator.save(TestsFactories.createCreateSentenceViewController(), sentence: "Test", definition: "Definition")

        XCTAssertEqual(inMemoryCoreData.fetchAllSentences()?.count, 1)
    }
}
