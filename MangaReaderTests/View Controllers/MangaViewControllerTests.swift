//
//  MangaViewControllerTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 26/11/20.
//

import XCTest
@testable import Kantan_Manga

class MangaViewControllerTests: XCTestCase {
    func testViewDidLoad_withEmptyNavigationBar_addsBackButtonToNavigationBar() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()

        XCTAssertEqual(mangaViewController.navigationItem.leftBarButtonItem?.title, "Back")
    }

    func testViewDidLoad_withEmptyNavigationBar_addsOCRButtonToNavigationBar() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()
        let buttonsImages = mangaViewController.navigationItem.rightBarButtonItems!.map { $0.image }

        XCTAssertTrue(buttonsImages.contains(UIImage(systemName: "magnifyingglass.circle")!))
    }

    func testViewDidLoad_withEmptyNavigationBar_addsSettingsButtonToNavigationBar() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()
        let buttonsImages = mangaViewController.navigationItem.rightBarButtonItems!.map { $0.image }

        XCTAssertTrue(buttonsImages.contains(UIImage(systemName: "gear")!))
    }

    func testViewDidLoad_withEmptyManga_callsInitialConfigurationOnDataSource() {
        let mockDataSource = FakeMangaDataSorce()
        let mangaViewController = TestsFactories.createMangaViewController(dataSource: mockDataSource)

        mangaViewController.loadViewIfNeeded()

        XCTAssertTrue(mockDataSource.initialConfigurationCalled)
    }

    func testViewDidLoad__pageControllerIsConstrainedToBorders() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()
        let constraints = ConstraintsUtils.getConstraintsWithFirstItem(ofType: "_UIPageViewControllerContentView", constraints: mangaViewController.view.constraints)

        // TODO: Test anchor type
        XCTAssertEqual(constraints.filter { ($0.secondItem as? UIView) == mangaViewController.view }.count, 4)
    }
}
