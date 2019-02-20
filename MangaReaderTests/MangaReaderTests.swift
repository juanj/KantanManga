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

class LibraryViewControllerTests: XCTestCase {
    func testCollectionViewDelegateAndDataSourceAreSetToViewController() {
        let libraryViewController = LibraryViewController()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        libraryViewController.collectionView = collectionView
        libraryViewController.configureCollectionView()
        
        XCTAssertEqual(libraryViewController.collectionView.delegate as? LibraryViewController, libraryViewController)
        XCTAssertEqual(libraryViewController.collectionView.dataSource as? LibraryViewController, libraryViewController)
    }
}
