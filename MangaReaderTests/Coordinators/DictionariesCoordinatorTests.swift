//
//  DictionariesCoordinatorTests.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import XCTest
@testable import Kantan_Manga

class DictionariesCoordinatorTests: XCTestCase {
    func testStart_withEmptyNavigationStack_pushesDictionariesViewController() {
        let mockNavigation = FakeNavigation()
        let dictionariesCoordinator = TestsFactories.createDictionariesCoordinator(navigable: mockNavigation)

        dictionariesCoordinator.start()

        XCTAssertNotNil(mockNavigation.viewControllers.last as? DictionariesViewController )
    }
}
