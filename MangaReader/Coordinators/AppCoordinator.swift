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
        if orientation == .portrait || orientation == .portraitUpsideDown {
            var viewController = UIViewController()
            
            if let viewControllers = pageViewController.viewControllers {
                if viewControllers.count == 2 {
                    viewController = viewControllers[1]
                } else {
                    viewController = viewControllers[0]
                }
            }
            if let viewController = viewController as? PageViewController {
                viewController.doublePaged = false
                viewController.refreshView()
            }
            pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            pageViewController.isDoubleSided = false
            return .max
        } else {
            var viewControllers = [UIViewController(), UIViewController()]
            
            if let pageViewControllers = pageViewController.viewControllers {
                if pageViewControllers.count == 2 {
                    viewControllers = pageViewControllers
                } else {
                    let viewController = pageViewControllers[0]
                    if let pageController = viewController as? PageViewController {
                        pageController.doublePaged = true
                        pageController.refreshView()
                        if pageController.page % 2 == 0 {
                            if let viewController2 = self.pageViewController(pageViewController, viewControllerBefore: viewController) {
                                viewControllers = [viewController2, viewController]
                            }
                        } else {
                            if let viewController2 = self.pageViewController(pageViewController, viewControllerAfter: viewController) {
                                viewControllers = [viewController, viewController2]
                            }
                        }
                    }
                }
            }
            pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
            pageViewController.isDoubleSided = true
            return .mid
        }
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
