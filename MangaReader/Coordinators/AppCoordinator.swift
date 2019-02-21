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
    init(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    func start() {
        let library = LibraryViewController()
        library.delegate = self
        library.mangas = self.loadMangas()
        self.navigationController.pushViewController(library, animated: false)
        self.libraryView = library
    }
    
    func loadMangas() -> [Manga] {
        return CoreDataManager.sharedManager.fetchAllMangas() ?? [Manga]()
    }
    
    func createPageController() -> UIPageViewController? {
        guard let manga = self.currentManga else {
            return nil
        }
        
        guard let dataSource = MangaDataSource(manga: manga) else {
            return nil
        }
        
        self.currentMangaDataSource = dataSource
        
        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [UIViewController]()
        
        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            spineLocation = .max
            doublePaged = false
            let page = dataSource.createPage(index: Int(manga.currentPage), doublePaged: doublePaged)
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
        
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: spineLocation.rawValue])
        pageController.isDoubleSided = doublePaged
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        return pageController
    }
}

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga) {
        self.currentManga = manga
        if let pageContorller = self.createPageController() {
            self.navigationController.pushViewController(pageContorller, animated: true)
            self.navigationController.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func didSelectAdd(_ libraryViewController: LibraryViewController) {
        let addMangasCoordinator = AddMangasCoordinator(navigation: self.navigationController)
        addMangasCoordinator.delegate = self
        self.childCoordinators.append(addMangasCoordinator)
        addMangasCoordinator.start()
    }
}

// MARK: AddMangasCoordinatorDelegate
extension AppCoordinator: AddMangasCoordinatorDelegate {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator) {
        self.childCoordinators.removeLast()
        let mangas = self.loadMangas()
        self.libraryView?.mangas = mangas
    }
}

extension AppCoordinator: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // Return next page to make manga RTL
        return self.currentMangaDataSource?.nextPage(currentPage: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // Return previous page to make manga RTL
        return self.currentMangaDataSource?.previousPage(currentPage: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [PageViewController]()
        
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
                        if let page2 = self.currentMangaDataSource?.nextPage(currentPage: page) as? PageViewController {
                            viewControllers = [page2, page]
                        }
                    } else {
                        // If first page is odd, get previous page
                        if let page2 = self.currentMangaDataSource?.previousPage(currentPage: page) as? PageViewController {
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
        if let pageView = pageViewController.viewControllers?[0] as? PageViewController, let manga = self.currentManga {
            CoreDataManager.sharedManager.updatePage(manga: manga, newPage: Int16(pageView.page))
        }
    }
}

extension AppCoordinator: PageViewControllerDelegate {
    func didSelectBack(_ pageViewController: PageViewController) {
        self.navigationController.popViewController(animated: true)
        self.navigationController.setNavigationBarHidden(false, animated: true)
    }
}
