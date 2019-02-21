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
    var currentMangaReader: CBZReader?
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
        
        guard let filePath = manga.filePath else {
            return nil
        }
        
        do {
            self.currentMangaReader = try CBZReader(fileName: filePath)
        } catch {
            print("Error creating CBZReader for path \(filePath)")
            return nil
        }
        
        let spineLocation: UIPageViewController.SpineLocation
        let doublePaged: Bool
        var viewControllers = [UIViewController]()
        
        let page1 = PageViewController()
        page1.page = 0
        self.currentMangaReader?.readEntityAt(index: page1.page, { (data) in
            if let data = data {
                page1.pageData.append(data)
            }
        })
        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            spineLocation = .max
            doublePaged = false
            viewControllers = [page1]
        } else {
            let page2 = PageViewController()
            page2.page = 1
            self.currentMangaReader?.readEntityAt(index: page2.page, { (data) in
                if let data = data{
                    page2.pageData.append(data)
                }
            })
            viewControllers = [page2, page1]
            spineLocation = .mid
            doublePaged = true
        }
        
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: [.spineLocation: spineLocation.rawValue])
        pageController.isDoubleSided = doublePaged
        pageController.delegate = self
        pageController.dataSource = self
        
        pageController.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: nil)
        return pageController
    }
}

// MARK: LibraryViewControllerDelegate
extension AppCoordinator: LibraryViewControllerDelegate {
    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga) {
        self.currentManga = manga
        if let pageContorller = self.createPageController() {
            self.navigationController.pushViewController(pageContorller, animated: true)
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
        guard let currentReader = self.currentMangaReader else {
            return PageViewController()
        }
        let view = PageViewController()
        if let viewController = viewController as? PageViewController {
            view.page = viewController.page + 1
        }
        if view.page > currentReader.fileEntries.count {
            return nil
        }
        currentReader.readEntityAt(index: view.page, { (data) in
            if let data = data{
                view.pageData.append(data)
            }
        })
        return view
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentReader = self.currentMangaReader else {
            return PageViewController()
        }
        let view = PageViewController()
        if let viewController = viewController as? PageViewController {
            view.page = viewController.page - 1
        }
        
        if view.page < 0 {
            return nil
        }
        
        currentReader.readEntityAt(index: view.page, { (data) in
            if let data = data{
                view.pageData.append(data)
            }
        })
        return view
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
}
