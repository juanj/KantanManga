//
//  ViewMangaCoordinatorTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 7/11/20.
//

import XCTest
@testable import Kantan_Manga

class ViewMangaCoordinatorTests: XCTestCase {
    func testStart_withEmptyNavigation_pushesMangaViewController() {
        let mockNavigation = FakeNavigation()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        viewMangaCoordinator.start()

        XCTAssertNotNil(mockNavigation.viewControllers.last as? MangaViewController)
    }

    func testStart_withEmptyUserDefaults_setsHasSeenMangaToTrue() {
        UserDefaults.resetStandardUserDefaults()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()

        viewMangaCoordinator.start()

        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasSeenManga"))
    }

    // MARK: MangaViewControllerDelegate
    func testMangaViewControllerDelegateDidTapPage_withFullScreenFalse_setsFullScreenTrue() {
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()
        let mockMangaViewController = TestsFactories.createMangaViewController(firstTime: true)

        _ = mockMangaViewController.view
        viewMangaCoordinator.didTapPage(mockMangaViewController, pageViewController: PageViewController(delegate: nil, pageSide: .center, pageNumber: 0))

        XCTAssertTrue(mockMangaViewController.prefersStatusBarHidden)
    }

    func testMangaViewControllerDelegateBack_withViewControllerOnNavigationStack_popsViewController() {
        let mockNavigation = FakeNavigation()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        mockNavigation.pushViewController(UIViewController(), animated: false)
        viewMangaCoordinator.back(TestsFactories.createMangaViewController())

        XCTAssertEqual(mockNavigation.viewControllers.count, 0)
    }

    func testMangaViewControllerDelegateDidSelectSectionOfImage_withEmptyImage_callsRecognizeOnOCR() {
        let mockOCR = FakeImageOcr()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(ocr: mockOCR)
        let mangaViewController = TestsFactories.createMangaViewController()

        _ = mangaViewController.view
        let image = UIImage(systemName: "0.circle.fill")!
        viewMangaCoordinator.didSelectSectionOfImage(TestsFactories.createMangaViewController(), image: image)

        XCTAssertTrue(mockOCR.recognizeCalls.contains(image))
    }

    func testMangaViewControllerDelegateDidTapSettings_withoutPresentedViewController_presentsViewcontroller() {
        let mockNavigation = FakeNavigation()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        viewMangaCoordinator.didTapSettings(TestsFactories.createMangaViewController())

        XCTAssertNotNil(mockNavigation.presentedViewController)
    }

    func testMangaViewControllerDelegatePageDidChange_withCurrentPageAt0_setsCorrectPage() {
        let mockCoreDataManager = InMemoryCoreDataManager()
        let manga = mockCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 10, filePath: "")!
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(coreDataManager: mockCoreDataManager, manga: manga)

        viewMangaCoordinator.pageDidChange(TestsFactories.createMangaViewController(), manga: manga, newPage: 5)

        XCTAssertEqual(mockCoreDataManager.fetchAllMangas()?.first?.currentPage, 5)
    }

    // MARK: UINavigationControllerDelegate
    func testUINavigationControllerDelegateAnimationControllerFor_fromCollectionViewController_isOpenMangaAnimationController() {
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()

        let animationController = viewMangaCoordinator.navigationController(UINavigationController(), animationControllerFor: .push, from: FakeCollectionViewController(delegate: FakeCollectionViewControllerDelgate(), collection: EmptyMangaCollection(mangas: []), sourcePoint: .zero, initialRotations: []), to: UIViewController())

        XCTAssertNotNil(animationController as? OpenMangaAnimationController)
    }

    func testUINavigationControllerDelegateAnimationControllerFor_fromGenericViewcontroller_isNill() {
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator()

        let animationController = viewMangaCoordinator.navigationController(UINavigationController(), animationControllerFor: .push, from: UIViewController(), to: UIViewController())

        XCTAssertNil(animationController)
    }

    // MARK: ViewerSettingsViewControllerDelegate
    func testViewerSettingsViewControllerDelegateUpdatePagesSetting_withDoublePagedTrue_forcesToggleModeOnDataSource() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let manga = stubCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        let mockDataSource = MangaDataSource(manga: manga, readerBuilder: { $1(FakeReader(fileName: $0)) })!
        let viewMangaCoordinator = TestsFactories.createTestableViewMangaCoordinator(mangaDataSource: mockDataSource)

        mockDataSource.forceToggleMode = false
        viewMangaCoordinator.updatePagesSetting(ViewerSettingsViewController(settings: [], delegate: FakeViewerSettingsViewControllerDelegate()), setting: .doublePaged(true), newValue: .bool(value: true))

        XCTAssertTrue(mockDataSource.forceToggleMode)
    }

    func testViewerSettingsViewControllerDelegateUpdatePagesSetting_withOffsetByOneTrue_setsPagesOffsetTrue() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let manga = stubCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        let mockDataSource = MangaDataSource(manga: manga, readerBuilder: { $1(FakeReader(fileName: $0)) })!
        let viewMangaCoordinator = TestsFactories.createTestableViewMangaCoordinator(mangaDataSource: mockDataSource)

        mockDataSource.pagesOffset = false
        viewMangaCoordinator.updatePagesSetting(ViewerSettingsViewController(settings: [], delegate: FakeViewerSettingsViewControllerDelegate()), setting: .offsetByOne(true), newValue: .bool(value: true))

        XCTAssertTrue(mockDataSource.pagesOffset)
    }

    func testViewerSettingsViewControllerDelegateUpdatePageNumbersSetting_withPageOffset10_setsPageTextOffset10() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let manga = stubCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        let mockDataSource = MangaDataSource(manga: manga, readerBuilder: { $1(FakeReader(fileName: $0)) })!
        let viewMangaCoordinator = TestsFactories.createTestableViewMangaCoordinator(mangaDataSource: mockDataSource)

        mockDataSource.pageTextOffset = 0
        viewMangaCoordinator.updatePageNumbersSetting(ViewerSettingsViewController(settings: [], delegate: FakeViewerSettingsViewControllerDelegate()), setting: .offsetPageNumbesr(10), newValue: .number(value: 10))

        XCTAssertEqual(mockDataSource.pageTextOffset, 10)
    }

    func testViewerSettingsViewControllerDelegateUpdatePageNumbersSetting_withHidePageNumbersTrue_setshHidePageLabelTrue() {
        let stubCoreDataManager = InMemoryCoreDataManager()
        let manga = stubCoreDataManager.insertManga(name: "Test", coverData: Data(), totalPages: 0, filePath: "")!
        let mockDataSource = MangaDataSource(manga: manga, readerBuilder: { $1(FakeReader(fileName: $0)) })!
        let viewMangaCoordinator = TestsFactories.createTestableViewMangaCoordinator(mangaDataSource: mockDataSource)

        mockDataSource.hidePageLabel = false
        viewMangaCoordinator.updatePageNumbersSetting(ViewerSettingsViewController(settings: [], delegate: FakeViewerSettingsViewControllerDelegate()), setting: .hidePageNumbers(true), newValue: .bool(value: true))

        XCTAssertTrue(mockDataSource.hidePageLabel)
    }

    func testViewerSettingsViewControllerDelegateDidSelectDone_withPResentedViewController_dismissViewController() {
        let mockNavigation = FakeNavigation()
        let viewMangaCoordinator = TestsFactories.createViewMangaCoordinator(navigable: mockNavigation)

        mockNavigation.present(UIViewController(), animated: false)
        viewMangaCoordinator.didSelectDone(ViewerSettingsViewController(settings: [], delegate: FakeViewerSettingsViewControllerDelegate()))

        XCTAssertNil(mockNavigation.presentedViewController)
    }
}
