//
//  MangaReaderTests.swift
//  MangaReaderTests
//
//  Created by admin on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import XCTest
@testable import MangaReader

class AppCoordinatorTests: XCTestCase {
    func testCallingStartPushLibraryViewController() {
        let navigation = UINavigationController()
        let appCoordinator = AppCoordinator(navigation: navigation)
        appCoordinator.start()
        
        XCTAssertTrue(navigation.viewControllers.first is LibraryViewController)
    }
}
