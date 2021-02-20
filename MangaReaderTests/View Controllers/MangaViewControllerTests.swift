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

    func testViewDidLoad_afterInitializing_pageControllerIsConstrainedToBorders() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()
        let constraints = ConstraintsUtils.getConstraintsWithFirstItem(ofType: "_UIPageViewControllerContentView", constraints: mangaViewController.view.constraints)

        let anchors = constraints.map { $0.firstAnchor }
            .map { ConstraintsUtils.getAnchorName($0) }
        XCTAssertEqual(Set(anchors), ["top", "bottom", "left", "right"])
    }

    func testViewDidLoad_afterInitializing_progresBarIsAdded() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()

        XCTAssertEqual(mangaViewController.view.subviews.filter { $0 is UISlider }.count, 1)
    }

    func testViewDidLoad_firstTimeTrue_doNotStartsInFullScreen() {
        let mangaViewController = TestsFactories.createMangaViewController(firstTime: true)

        mangaViewController.loadViewIfNeeded()

        XCTAssertEqual(mangaViewController.prefersStatusBarHidden, false)
    }

    func testViewDidLoad_firstTimeFalse_startsInFullScreen() {
        let mangaViewController = TestsFactories.createMangaViewController(firstTime: false)

        mangaViewController.loadViewIfNeeded()

        XCTAssertEqual(mangaViewController.prefersStatusBarHidden, true)
    }

    func testViewDidAppear_firstTimeTrue_addsHelpOverlayToRootViewController() {
        let mangaViewController = TestsFactories.createMangaViewController(firstTime: true)

        mangaViewController.loadViewIfNeeded()
        mangaViewController.viewDidAppear(false)

        XCTAssertEqual(UIApplication.shared.windows.first?.rootViewController?.view.subviews.filter { $0 is FocusOverlayView }.count, 1)
    }

    func testViewDidAppear_firstTimeFalse_doNotAddsHelpOverlayToRootViewController() {
        let mangaViewController = TestsFactories.createMangaViewController(firstTime: false)

        mangaViewController.viewDidAppear(false)

        XCTAssertEqual(UIApplication.shared.windows.first?.rootViewController?.view.subviews.filter { $0 is FocusOverlayView }.count, 0)
    }

    func testReloadPageController_withEmptyManga_callsInitialConfigurationOnDataSource() {
        let mockDataSource = FakeMangaDataSorce()
        let mangaViewController = TestsFactories.createMangaViewController(dataSource: mockDataSource)

        mangaViewController.loadViewIfNeeded()
        mockDataSource.initialConfigurationCalled = false
        mangaViewController.reloadPageController()

        XCTAssertTrue(mockDataSource.initialConfigurationCalled)
    }

    func testToggleFullscreen_onFullScreen_togglesFullScreen() {
        let mangaViewController = TestsFactories.createMangaViewController()

        mangaViewController.loadViewIfNeeded()
        mangaViewController.toggleFullscreen()

        XCTAssertFalse(mangaViewController.prefersStatusBarHidden)
    }

    func testBack_withDelegate_callsBackOnDelegate() {
        let mockDelegate = FakeMangaViewControllerDelegate()
        let mangaViewController = TestsFactories.createMangaViewController(delegate: mockDelegate)

        mangaViewController.back()

        XCTAssertTrue(mockDelegate.backCalled)
    }

    func testToggleOcr_withoutFullScreen_togglesFullScreen() {
        let mangaViewController = TestsFactories.createMangaViewController(firstTime: true)

        mangaViewController.loadViewIfNeeded()
        mangaViewController.toggleOcr()

        XCTAssertTrue(mangaViewController.prefersStatusBarHidden)
    }

    func testOpenSettings_withDelegate_callsDidTapSettingsOnDelegate() {
        let mockDelegate = FakeMangaViewControllerDelegate()
        let mangaViewController = TestsFactories.createMangaViewController(delegate: mockDelegate)

        mangaViewController.openSettings()

        XCTAssertTrue(mockDelegate.openSettingsCalled)
    }

    func testMovePage_withDelegate_callsPageDidChangeOnDelegate() {
        let mockDelegate = FakeMangaViewControllerDelegate()
        let mangaViewController = TestsFactories.createMangaViewController(delegate: mockDelegate)

        mangaViewController.loadViewIfNeeded()
        let slider = mangaViewController.view.subviews.filter { $0 is UISlider }.first as! UISlider // swiftlint:disable:this force_cast
        slider.maximumValue = 5
        slider.value = 2
        mangaViewController.movePage()

        XCTAssertTrue(mockDelegate.pageDidChangeCalled)
    }

    func testMovePage_withDataSource_callsInitialConfigurationOnDataSource() {
        let mockDataSource = FakeMangaDataSorce()
        let mangaViewController = TestsFactories.createMangaViewController(dataSource: mockDataSource)

        mangaViewController.loadViewIfNeeded()
        let slider = mangaViewController.view.subviews.filter { $0 is UISlider }.first as! UISlider // swiftlint:disable:this force_cast
        slider.maximumValue = 5
        slider.value = 2
        mockDataSource.initialConfigurationCalled = false
        mangaViewController.movePage()

        XCTAssertTrue(mockDataSource.initialConfigurationCalled)
    }

    func testBeganLongPress_withNoOcrEnabled_togglesOcr() {
        let mangaViewController = TestsFactories.createMangaViewController(firstTime: true, testable: true)

        mangaViewController.loadViewIfNeeded()
        let tap = UILongPressGestureRecognizer()
        tap.state = .began
        mangaViewController.longPress(tap: tap)

        XCTAssertTrue(mangaViewController.prefersStatusBarHidden)
    }
}
