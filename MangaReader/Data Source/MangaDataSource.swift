//
//  MangaDataSource.swift
//  MangaReader
//
//  Created by Juan on 2/21/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol MangaDataSourceDelegate: AnyObject {
    func shouldLoadPage(_ mangaDataSource: MangaDataSourceable) -> Bool
}

class MangaDataSource: NSObject, MangaDataSourceable {
    var forceToggleMode = false
    var pagesOffset = false
    var pageTextOffset = 0
    var hidePageLabel = false
    weak var delegate: MangaDataSourceDelegate?
    private var mangaReader: Reader!
    private let manga: Manga

    private let cache = NSCache<NSString, UIImage>()
    private var queue = [(PageViewController, Int)]()

    required init?(manga: Manga, readerBuilder: (_ path: String, _ completion: @escaping (Reader) -> Void) -> Void) {
        self.manga = manga
        super.init()
        guard let path = manga.filePath else {
            return nil
        }

        // Injection of async dependency
        readerBuilder(path) { reader in
            self.mangaReader = reader
            self.clearQueue()
            self.preloadPages()
        }
    }

    private func spinLocation(with orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        let landscapeOrientations: [UIInterfaceOrientation] = [.landscapeLeft, .landscapeRight]
        var doublePaged = landscapeOrientations.contains(orientation)
        doublePaged = forceToggleMode ? !doublePaged : doublePaged

        return doublePaged ? .mid : .max
    }

    func initialConfiguration(with orientation: UIInterfaceOrientation, and viewControllers: [UIViewController]? = nil, startingPage: Int, delegate: PageViewControllerDelegate? = nil, fullScreen: Bool = true) -> (UIPageViewController.SpineLocation, [PageViewController]) {
        let location = spinLocation(with: orientation)
        var pageViewControllers = [PageViewController]()
        switch location {
        case .max:
            pageViewControllers = initialSinglePageConfiguration(viewControllers: viewControllers ?? [], startingPage: startingPage, delegate: delegate)
        case .mid:
            pageViewControllers = initialDoublePageConfiguration(viewControllers: viewControllers ?? [], startingPage: startingPage, delegate: delegate)
        default:
            break
        }

        return (location, pageViewControllers)
    }

    private func initialSinglePageConfiguration(viewControllers: [UIViewController], startingPage: Int, delegate: PageViewControllerDelegate?) -> [PageViewController] {
        if let pages = viewControllers as? [PageViewController], pages.count > 0 {
            // Reuse current pages
            let page: PageViewController
            if pages.count == 2 {
                // Two pages. Keep the one on the right.
                page = pages[1]
            } else {
                // Just one page. Use the same
                page = pages[0]
            }
            page.pageSide = .center
            page.refreshView()
            return [page]
        } else {
            // Create pages
            let page = createPage(index: startingPage, side: .center, delegate: delegate, fullScreen: true)
            return [page]
        }
    }

    private func initialDoublePageConfiguration(viewControllers: [UIViewController], startingPage: Int, delegate: PageViewControllerDelegate?) -> [PageViewController] {
        if let pages = viewControllers as? [PageViewController], pages.count > 0 {
            // Reuse current pages
            if pages.count == 2 {
                pages[0].pageSide = .left
                pages[0].refreshView()
                pages[1].pageSide = .right
                pages[1].refreshView()
                return pages
            } else {
                let page = pages[0]
                if page.pageNumber % 2 == 0 {
                    // If first page is even, get next page
                    page.pageSide = .right
                    page.refreshView()
                    if let page2 = nextPage(currentPage: page) as? PageViewController {
                        return [page2, page]
                    }
                } else {
                    // If first page is odd, get previous page
                    page.pageSide = .left
                    page.refreshView()
                    if let page2 = previousPage(currentPage: page) as? PageViewController {
                        return [page, page2]
                    }
                }
            }
        } else {
            // Create pages
            if startingPage % 2 == 1 {
                let page1 = createPage(index: startingPage - 1 + pagesOffset.intValue, side: .right, delegate: delegate)
                let page2 = createPage(index: startingPage + pagesOffset.intValue, side: .left, delegate: delegate)

                // Set view controllers in this order to make manga RTL
                return [page2, page1]
            } else {
                let page1 = createPage(index: startingPage + pagesOffset.intValue, side: .right, delegate: delegate)
                let page2 = createPage(index: startingPage + 1 + pagesOffset.intValue, side: .left, delegate: delegate)

                // Set view controllers in this order to make manga RTL
                return [page2, page1]
            }
        }
        return []
    }

    func createPage(index: Int, side: PageViewController.Side = .center, delegate: PageViewControllerDelegate?, fullScreen: Bool = false) -> PageViewController {
        let page = PageViewController(delegate: delegate, pageSide: side, pageNumber: index, pageText: String(index + 1 + pageTextOffset), hidePageNumbers: hidePageLabel, isFullScreened: fullScreen)

        // Load image to page
        if mangaReader == nil {
            queue.append((page, index))
        } else {
            getImageForPage(index: index) { (image) in
                DispatchQueue.main.async {
                    page.pageImage = image
                }
            }
        }

        return page
    }

    func nextPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController, mangaReader != nil else { return nil }

        let index = currentPage.pageNumber + 1
        guard index < mangaReader.numberOfPages else {
            // End of manga
            return nil
        }

        getImageForPage(index: index + 10)
        return createPage(index: index, side: currentPage.pageSide.opposite(), delegate: currentPage.delegate, fullScreen: currentPage.isFullScreened)
    }

    func previousPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController else { return nil }

        let index = currentPage.pageNumber - 1
        guard index >= 0 else {
            // End of manga
            return nil
        }

        getImageForPage(index: index - 10)
        return createPage(index: index, side: currentPage.pageSide.opposite(), delegate: currentPage.delegate, fullScreen: currentPage.isFullScreened)
    }

    private func clearQueue() {
        for (page, index) in queue {
            getImageForPage(index: index) { (image) in
                DispatchQueue.main.async {
                    page.pageImage = image
                }
            }
        }
    }

    private func preloadPages() {
        let currentPage = Int(manga.currentPage)

        // Load current pages
        let serialQueue = DispatchQueue(label: "imagesPreload")
        let group = DispatchGroup()

        // Preload next 10 and previous 10 pages sequentialy
        let nextOffsets = 1...10
        let previouOffsets = (-10 ... -1).reversed()
        let offsets = zip(nextOffsets, previouOffsets).flatMap { [$0.0, $0.1] }

        group.enter()
        serialQueue.async {
            self.getImageForPage(index: currentPage) { (_) in
                group.leave()
            }
        }

        for pageOffset in offsets {
            serialQueue.async {
                group.wait()
                group.enter()
                self.getImageForPage(index: currentPage - pageOffset) { (_) in
                    group.leave()
                }
            }
        }

    }

    private func getImageForPage(index: Int, callBack: ((UIImage?) -> Void)? = nil) {
        guard mangaReader != nil else {
            callBack?(nil)
            return
        }

        if let imageInCache = cache.object(forKey: String(index) as NSString) {
            callBack?(imageInCache)
        } else {
            mangaReader.readEntityAt(index: index) { (data) in
                guard let data = data, let image = UIImage(data: data) else {
                    callBack?(nil)
                    return
                }

                // Dictionaries are not thread safe.
                DispatchQueue.main.async {
                    self.cache.setObject(image, forKey: String(index) as NSString)
                    callBack?(image)
                }
            }
        }
    }
}

extension MangaDataSource: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard delegate?.shouldLoadPage(self) != false else { return nil }
        // Return next page to make manga RTL
        if let previousPage = nextPage(currentPage: viewController) {
            return previousPage
        } else if pageViewController.spineLocation == .mid, pagesOffset, let currentPage = viewController as? PageViewController, currentPage.pageNumber == mangaReader.numberOfPages - 1 {
            // If is double paged and is offset, return a blank padding page
            let page = PageViewController(delegate: currentPage.delegate, pageSide: currentPage.pageSide.opposite(), pageNumber: currentPage.pageNumber + 1, isPaddingPage: true)
            return page
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard delegate?.shouldLoadPage(self) != false else { return nil }
        // Return previous page to make manga RTL
        if let previousPage = previousPage(currentPage: viewController) {
            return previousPage
        } else if pageViewController.spineLocation == .mid, pagesOffset, let currentPage = viewController as? PageViewController, currentPage.pageNumber == 0 {
            // If is double paged and is offset, return a blank padding page
            let page = PageViewController(delegate: currentPage.delegate, pageSide: currentPage.pageSide.opposite(), pageNumber: -1, isPaddingPage: true)
            return page
        }
        return nil
    }
}
