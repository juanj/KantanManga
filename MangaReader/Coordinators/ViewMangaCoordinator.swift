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
    func didEnd(viewMangaCoordinator: ViewMangaCoordinator)
}

class ViewMangaCoordinator: NSObject {
    private let navigationController: UINavigationController!
    private weak var delegate: ViewMangaCoordinatorDelegate?
    private let manga: Manga
    private let originFrame: CGRect

    private var mangaDataSource: MangaDataSource!

    init(navigation: UINavigationController, manga: Manga, delegate: ViewMangaCoordinatorDelegate, originFrame: CGRect) {
        navigationController = navigation
        self.manga = manga
        self.delegate = delegate
        self.originFrame = originFrame
        mangaDataSource = MangaDataSource(manga: manga)
    }

    func start() {
        guard mangaDataSource != nil else {
            delegate?.didEnd(viewMangaCoordinator: self)
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
    func didTapPage(mangaViewController: MangaViewController, pageViewController: PageViewController) {
        mangaViewController.toggleFullscreen()
    }

    func back(mangaViewController: MangaViewController) {
        navigationController.popViewController(animated: true)
        delegate?.didEnd(viewMangaCoordinator: self)
    }

    func didSelectSectionOfImage(mangaViewController: MangaViewController, image: UIImage) {
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ja"]
        let textRecognizer = vision.cloudTextRecognizer(options: options)
        let visionImage = VisionImage(image: image)

        mangaViewController.setSentence(sentence: "")
        mangaViewController.ocrStartLoading()

        textRecognizer.process(visionImage) { result, error in
            DispatchQueue.main.async {
                mangaViewController.ocrEndLoading()
            }
            if let error = error {
                print(error.localizedDescription)
            }
            guard let result = result else { return }

            let text = result.text.replacingOccurrences(of: "\n", with: " ")
            DispatchQueue.main.async {
                mangaViewController.setSentence(sentence: text)
            }
        }
    }
}

extension ViewMangaCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is LibraryViewController {
            let image = manga.coverImage ?? UIImage()
            return OpenMangaAnimationController(originFrame: originFrame, mangaCover: image)
        }
        return nil
    }
}
