//
//  AppCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import CoreData

class AppCoordinator: NSObject {
    var navigationController: UINavigationController
    var childCoordinators = [Any]()

    var currentManga: Manga?
    var currentMangaDataSource: MangaDataSource?
    var libraryView: LibraryViewController?
    var pageController: FullScreenPageViewController?

    var isPageAnimating = false
    init(navigation: UINavigationController) {
        navigationController = navigation
    }

    func start() {
        let library = LibraryViewController()
        library.delegate = self
        library.mangas = loadMangas()
        navigationController.pushViewController(library, animated: false)
        libraryView = library
    }

    func loadMangas() -> [Manga] {
        return CoreDataManager.sharedManager.fetchAllMangas() ?? [Manga]()
    }

    func createPageController() -> FullScreenPageViewController? {
        guard let manga = currentManga else {
            return nil
        }

        guard let dataSource = MangaDataSource(manga: manga) else {
            return nil
        }

        currentMangaDataSource = dataSource

        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [UIViewController]()

        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
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

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectDeleteManga(_ libraryViewController: LibraryViewController, manga: Manga) {
        CoreDataManager.sharedManager.delete(manga: manga)
        libraryViewController.mangas = loadMangas()
        libraryViewController.collectionView.reloadData()
    }

    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga) {
        currentManga = manga
        if let pageContorller = createPageController() {
            pageController = pageContorller
            navigationController.pushViewController(pageContorller, animated: true)
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }

    func didSelectAdd(_ libraryViewController: LibraryViewController) {
        let addMangasCoordinator = AddMangasCoordinator(navigation: navigationController)
        addMangasCoordinator.delegate = self
        childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }
}

// MARK: AddMangasCoordinatorDelegate
extension AppCoordinator: AddMangasCoordinatorDelegate {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator) {
        childCoordinators.removeLast()
        let mangas = loadMangas()
        libraryView?.mangas = mangas
    }
}

extension AppCoordinator: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if isPageAnimating {
            return nil
        }
        // Return next page to make manga RTL
        return currentMangaDataSource?.nextPage(currentPage: viewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if isPageAnimating {
            return nil
        }
        // Return previous page to make manga RTL
        return currentMangaDataSource?.previousPage(currentPage: viewController)
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
        case .landscapeLeft, .landscapeRight, .unknown:
            spineLocation = .mid
            doublePaged = true
            if let pages = pageViewController.viewControllers as? [PageViewController] {
                if pages.count == 2 {
                    viewControllers = pages
                } else {
                    let page = pages[0]
                    if page.page % 2 == 0 {
                        // If first page is even, get next page
                        if let page2 = currentMangaDataSource?.nextPage(currentPage: page) as? PageViewController {
                            viewControllers = [page2, page]
                        }
                    } else {
                        // If first page is odd, get previous page
                        if let page2 = currentMangaDataSource?.previousPage(currentPage: page) as? PageViewController {
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
        if let pageView = pageViewController.viewControllers?[0] as? PageViewController, let manga = currentManga {
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

extension AppCoordinator: PageViewControllerDelegate {
    func didLongPress(_ pageViewController: PageViewController) {
        let detail = PageDetailViewController()
        detail.image = pageViewController.pageImageView?.image
        detail.delegate = self
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(detail, animated: true)
    }

    func didTap(_ pageViewController: PageViewController) {
        if let pageController = pageController {
            pageController.troggleFullscreen()
            if let pages = pageController.viewControllers as? [PageViewController] {
                for page in pages {
                    page.toggleBars()
                }
            }
        }
    }

    func didSelectBack(_ pageViewController: PageViewController) {
        navigationController.popViewController(animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)
    }
}

extension AppCoordinator: PageDetailViewControllerDelegate {
    func didSelectBack(_ pageDetailViewController: PageDetailViewController) {
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.popViewController(animated: true)
    }
}
