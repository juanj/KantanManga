//
//  ViewMangaCoordinator.swift
//  MangaReader
//
//  Created by Juan on 26/11/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import Foundation
import Firebase

protocol ViewMangaCoordinatorDelegate: AnyObject {
    func didEnd(_ viewMangaCoordinator: ViewMangaCoordinator)
}

class ViewMangaCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private let navigationController: UINavigationController!
    private weak var delegate: ViewMangaCoordinatorDelegate?
    private let manga: Manga
    private let originFrame: CGRect

    private var mangaDataSource: MangaDataSource!
    private var ocr: ImageOCR

    init(navigation: UINavigationController, manga: Manga, delegate: ViewMangaCoordinatorDelegate, originFrame: CGRect, ocr: ImageOCR) {
        navigationController = navigation
        self.manga = manga
        self.delegate = delegate
        self.originFrame = originFrame
        self.ocr = ocr
        mangaDataSource = MangaDataSource(manga: manga)
    }

    func start() {
        guard mangaDataSource != nil else {
            delegate?.didEnd(self)
            return
        }
        let mangaView = MangaViewController(manga: manga, dataSource: mangaDataSource, delegate: self)
        navigationController.delegate = self
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(mangaView, animated: true)
    }
}

// MARK: MangaViewControllerDelegate
extension ViewMangaCoordinator: MangaViewControllerDelegate {
    func didTapPage(_ mangaViewController: MangaViewController, pageViewController: PageViewController) {
        mangaViewController.toggleFullscreen()
    }

    func back(_ mangaViewController: MangaViewController) {
        navigationController.popViewController(animated: true)
        delegate?.didEnd(self)
    }

    func didSelectSectionOfImage(_ mangaViewController: MangaViewController, image: UIImage) {
        mangaViewController.setSentence(sentence: "")
        mangaViewController.ocrStartLoading()
        ocr.recognize(image: image) { (result) in
            DispatchQueue.main.async {
                mangaViewController.ocrEndLoading()
            }
            switch result {
            case let .success(text):
                DispatchQueue.main.async {
                    mangaViewController.setSentence(sentence: text)
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewMangaCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is CollectionViewController {
            let image = manga.coverImage ?? UIImage()
            return OpenMangaAnimationController(originFrame: originFrame, mangaCover: image)
        }
        return nil
    }
}
