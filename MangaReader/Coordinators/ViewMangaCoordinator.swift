//
//  ViewMangaCoordinator.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import Foundation

protocol ViewMangaCoordinatorDelegate: AnyObject {
    func didEnd(viewMangaCoordinator: ViewMangaCoordinator)
}

class ViewMangaCoordinator: NSObject {
    private let navigationController: UINavigationController!
    private weak var delegate: ViewMangaCoordinatorDelegate?
    private let manga: Manga

    private var mangaDataSource: MangaDataSource!
    //private var pageController: FullScreenPageViewController!

    init(navigation: UINavigationController, manga: Manga, delegate: ViewMangaCoordinatorDelegate) {
        navigationController = navigation
        self.manga = manga
        self.delegate = delegate
        mangaDataSource = MangaDataSource(manga: manga)
    }

    func start() {
        guard mangaDataSource != nil else {
            delegate?.didEnd(viewMangaCoordinator: self)
            return
        }
        //pageController = createPageController()
        navigationController.pushViewController(MangaViewController(manga: manga, dataSource: mangaDataSource, delegate: self), animated: true)
    }
}

// MARK: MangaViewControllerDelegate
extension ViewMangaCoordinator: MangaViewControllerDelegate {
    func didTapPage(mangaViewController: MangaViewController, pageViewController: PageViewController) {
        navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
        mangaViewController.toggleFullscreen()
    }

    func back(mangaViewController: MangaViewController) {
        navigationController.popViewController(animated: true)
        delegate?.didEnd(viewMangaCoordinator: self)
    }
}
