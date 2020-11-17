//
//  MangaDataSourceTests.swift
//  Kantan-MangaTests
//
//  Created by Juan on 16/11/20.
//

import XCTest
@testable import Kantan_Manga

class MangaDataSourceTests: XCTestCase {
    func createEmptyManga() -> Manga {
        let coreDataManager = InMemoryCoreDataManager()
        let manga = coreDataManager.insertManga(name: "Empty", coverData: Data(), totalPages: 0, filePath: "empty.cbz")!
        return manga
    }

    func testInitialConfiguration_inLandscape_returns2Pages() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!

        let (_, pages) = dataSource.initialConfiguration(with: .landscapeLeft, startingPage: 0)

        XCTAssertEqual(pages.count, 2)
    }

    func testInitialConfiguration_withOldDoublePages_reusesPages() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!

        let (_, oldPages) = dataSource.initialConfiguration(with: .landscapeLeft, startingPage: 0)
        let (_, newPages) = dataSource.initialConfiguration(with: .landscapeLeft, and: oldPages, startingPage: 0)

        XCTAssertTrue(oldPages.first === newPages.first)
        XCTAssertTrue(oldPages.last === newPages.last)
    }

    func testInitialConfiguration_inLandscapeForceToggle_returns1Page() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!

        dataSource.forceToggleMode = true
        let (_, pages) = dataSource.initialConfiguration(with: .landscapeLeft, startingPage: 0)

        XCTAssertEqual(pages.count, 1)
    }

    func testInitialConfiguration_inPortrait_returns1Page() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!

        let (_, pages) = dataSource.initialConfiguration(with: .portrait, startingPage: 0)

        XCTAssertEqual(pages.count, 1)
    }

    func testInitialConfiguration_withOldPage_reusesPage() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!

        let (_, oldPages) = dataSource.initialConfiguration(with: .portrait, startingPage: 0)
        let (_, newPages) = dataSource.initialConfiguration(with: .portrait, and: oldPages, startingPage: 0)

        XCTAssertTrue(oldPages.first === newPages.first)
    }

    func testInitialConfiguration_inPortraitForceToggle_returns2Page() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!

        dataSource.forceToggleMode = true
        let (_, pages) = dataSource.initialConfiguration(with: .portrait, startingPage: 0)

        XCTAssertEqual(pages.count, 2)
    }

    func testCreatePage_withIndex100_callsReadEntityAtWithIndex100() {
        let emptyManga = createEmptyManga()
        let mockReader = FakeReader(fileName: "test.cbz")
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(mockReader)
        }!

        _ = dataSource.createPage(index: 100, delegate: nil)

        XCTAssertTrue(mockReader.readEntries.contains(100))
    }

    func testNextPage_withPagesAvailable_returnsNextPage() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        fakeReader.numberOfPages = 200
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!

        let currentPage = dataSource.createPage(index: 100, delegate: nil)
        let nextPage = dataSource.nextPage(currentPage: currentPage) as! PageViewController // swiftlint:disable:this force_cast

        XCTAssertEqual(nextPage.pageNumber, 101)
    }

    func testNextPage_inLastPage_returnsNil() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        fakeReader.numberOfPages = 100
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!

        let currentPage = dataSource.createPage(index: 100, delegate: nil)
        let nextPage = dataSource.nextPage(currentPage: currentPage)

        XCTAssertNil(nextPage)
    }

    func testPreviousPage_withPagesAvailable_returnsPreviousPage() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        fakeReader.numberOfPages = 200
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!

        let currentPage = dataSource.createPage(index: 100, delegate: nil)
        let nextPage = dataSource.previousPage(currentPage: currentPage) as! PageViewController // swiftlint:disable:this force_cast

        XCTAssertEqual(nextPage.pageNumber, 99)
    }

    func testPreviousPage_inFirstPage_returnsNil() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!

        let currentPage = dataSource.createPage(index: 0, delegate: nil)
        let nextPage = dataSource.previousPage(currentPage: currentPage)

        XCTAssertNil(nextPage)
    }

    func testPageViewControllerViewControllerBefore_withPagesAvailabel_returnsNextPage() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        fakeReader.numberOfPages = 200
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!

        let currentPage = dataSource.createPage(index: 100, delegate: nil)
        let nextPage = dataSource.pageViewController(UIPageViewController(), viewControllerBefore: currentPage) as! PageViewController // swiftlint:disable:this force_cast

        XCTAssertEqual(nextPage.pageNumber, 101)
    }

    func testPageViewControllerViewControllerBefore_doublePagedWithLastPageEvenAndOffsetTrue_returnsPaddingPage() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        fakeReader.numberOfPages = 100
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!
        dataSource.pagesOffset = true

        let currentPage = dataSource.createPage(index: 99, delegate: nil)
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: UIPageViewController.SpineLocation.mid.rawValue])
        let nextPage = dataSource.pageViewController(pageController, viewControllerBefore: currentPage) as! PageViewController // swiftlint:disable:this force_cast

        XCTAssertTrue(nextPage.isPaddingPage)
    }

    func testPageViewControllerViewControllerAfter_withPagesAvailabel_returnsPreviousPage() {
        let emptyManga = createEmptyManga()
        let fakeReader = FakeReader(fileName: "test.cbz")
        fakeReader.numberOfPages = 200
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(fakeReader)
        }!

        let currentPage = dataSource.createPage(index: 100, delegate: nil)
        let nextPage = dataSource.pageViewController(UIPageViewController(), viewControllerAfter: currentPage) as! PageViewController // swiftlint:disable:this force_cast

        XCTAssertEqual(nextPage.pageNumber, 99)
    }

    func testPageViewControllerViewControllerAfter_doublePagedOffsetTrue_returnsPaddingPage() {
        let emptyManga = createEmptyManga()
        let dataSource = MangaDataSource(manga: emptyManga) { _, completion in
            completion(FakeReader(fileName: "test.cbz"))
        }!
        dataSource.pagesOffset = true

        let currentPage = dataSource.createPage(index: 0, delegate: nil)
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: UIPageViewController.SpineLocation.mid.rawValue])
        let nextPage = dataSource.pageViewController(pageController, viewControllerAfter: currentPage) as! PageViewController // swiftlint:disable:this force_cast

        XCTAssertTrue(nextPage.isPaddingPage)
    }
}
