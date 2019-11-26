//
//  ViewMangaCoordinator.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import Foundation

protocol ViewMangaCoordinatorDelegate: AnyObject {

}

class ViewMangaCoordinator: NSObject {
    private let navigationController: UINavigationController!
    private weak var delegate: ViewMangaCoordinatorDelegate?
    private let manga: Manga

    private var mangaDataSource: MangaDataSource?
    private var pageController: FullScreenPageViewController?
    private var isPageAnimating = false

    init(navigation: UINavigationController, manga: Manga, delegate: ViewMangaCoordinatorDelegate) {
        navigationController = navigation
        self.manga = manga
        self.delegate = delegate
        mangaDataSource = MangaDataSource(manga: manga)
    }

    func start() {
        if let pageContorller = createPageController() {
            pageController = pageContorller
            navigationController.pushViewController(pageContorller, animated: true)
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }

    func createPageController() -> FullScreenPageViewController? {
        guard let dataSource = mangaDataSource else {
            return nil
        }

        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [UIViewController]()

        if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation, orientation == .portraitUpsideDown || orientation == .portrait {
            spineLocation = .max
            doublePaged = false
            let page = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged, delegate: self)
            viewControllers = [page]
        } else {
            spineLocation = .mid
            doublePaged = true

            if manga.currentPage % 2 == 1 {
                let page1 = dataSource.createPage(index: Int(manga.currentPage - 1), doublePaged: doublePaged, delegate: self)
                let page2 = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged, delegate: self)

                // Set view controllers in this order to make manga RTL
                viewControllers = [page2, page1]
            } else {
                let page1 = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged, delegate: self)
                let page2 = dataSource.createPage(index: Int(manga.currentPage + 1), doublePaged: doublePaged, delegate: self)

                // Set view controllers in this order to make manga RTL
                viewControllers = [page2, page1]
            }
        }

        let pageController = FullScreenPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: spineLocation.rawValue])
        pageController.isDoubleSided = doublePaged
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        return pageController
    }
}

// MARK: PageViewControllerDelegate
extension ViewMangaCoordinator: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if isPageAnimating {
            return nil
        }
        // Return next page to make manga RTL
        return mangaDataSource?.nextPage(currentPage: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if isPageAnimating {
            return nil
        }
        // Return previous page to make manga RTL
        return mangaDataSource?.previousPage(currentPage: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [PageViewController]()

        isPageAnimating = false

        switch orientation {
        case .portrait, .portraitUpsideDown:
            spineLocation = .max
            doublePaged = false
            if let pages = pageViewController.viewControllers as? [PageViewController] {
                if pages.count == 2 {
                    // Two pages. Keep the one on the right.
                    viewControllers = [pages[1]]
                } else {
                    // Just one page. Use the same
                    viewControllers = pages
                }
            }
        default:
            //.landscapeLeft, .landscapeRight, .unknown:
            spineLocation = .mid
            doublePaged = true
            if let pages = pageViewController.viewControllers as? [PageViewController] {
                if pages.count == 2 {
                    viewControllers = pages
                } else {
                    let page = pages[0]
                    if page.page % 2 == 0 {
                        // If first page is even, get next page
                        if let page2 = mangaDataSource?.nextPage(currentPage: page) as? PageViewController {
                            viewControllers = [page2, page]
                        }
                    } else {
                        // If first page is odd, get previous page
                        if let page2 = mangaDataSource?.previousPage(currentPage: page) as? PageViewController {
                            viewControllers = [page, page2]
                        }
                    }
                }
            }
        }

        for page in viewControllers {
            page.doublePaged = doublePaged
            page.refreshView()
        }

        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        pageViewController.isDoubleSided = doublePaged

        return spineLocation
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let pageView = pageViewController.viewControllers?[0] as? PageViewController {
            CoreDataManager.sharedManager.updatePage(manga: manga, newPage: Int16(pageView.page))
        }

        if completed || finished {
            isPageAnimating = false
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        isPageAnimating = true
    }
}

// MARK: PageViewControllerDelegate
extension ViewMangaCoordinator: PageViewControllerDelegate {
    func didTap(_ pageViewController: PageViewController) {
        if let pageController = pageController {
            pageController.troggleFullscreen()
            if let pages = pageController.viewControllers as? [PageViewController] {
                for page in pages {
                    //page.toggleBars()
                }
            }
        }
    }

    func didSelectBack(_ pageViewController: PageViewController) {
        navigationController.popViewController(animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)
    }
}
