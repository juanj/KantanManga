//
//  CreateSentenceCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import Foundation
import CropViewController

protocol CreateSentenceCoordinatorDelegate: AnyObject {
    func didEnd(_ createSentenceCoordinator: CreateSentenceCoordinator)
}

class CreateSentenceCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private var presentedNavigation: Navigable!
    private var currentCrop: CGRect?
    private var croppedImage: UIImage?
    private var createSentenceViewController: CreateSentenceViewController?

    private let navigation: Navigable
    private let image: UIImage
    private let sentence: String
    private let term: Term
    private let coreDataManager: CoreDataManageable
    private weak var delegate: CreateSentenceCoordinatorDelegate?
    init(navigation: Navigable, image: UIImage, sentence: String, term: Term, coreDataManager: CoreDataManageable, delegate: CreateSentenceCoordinatorDelegate?) {
        self.navigation = navigation
        self.image = image
        self.sentence = sentence
        self.term = term
        self.coreDataManager = coreDataManager
        self.delegate = delegate
    }

    func start() {
        let createSentenceViewController = CreateSentenceViewController(image: image, sentence: sentence, term: term, delegate: self)
        presentedNavigation = createPresentableNavigation()
        presentedNavigation.setViewControllers([createSentenceViewController], animated: false)

        navigation.present(presentedNavigation, animated: true, completion: nil)
        self.createSentenceViewController = createSentenceViewController
    }

    func createPresentableNavigation() -> Navigable {
        return UINavigationController()
    }
}

extension CreateSentenceCoordinator: CreateSentenceViewControllerDelegate {
    func cancel(_ createSentenceViewController: CreateSentenceViewController) {
        navigation.dismiss(animated: true, completion: nil)
        delegate?.didEnd(self)
    }

    func save(_ createSentenceViewController: CreateSentenceViewController, sentence: String, definition: String) {
        coreDataManager.insertSentence(sentence: sentence, definition: definition, image: croppedImage ?? image)
        navigation.dismiss(animated: true, completion: nil)
        delegate?.didEnd(self)
    }

    func editImage(_ createSentenceViewController: CreateSentenceViewController) {
        let cropViewController = CropViewController(image: image)
        if let currentCrop = currentCrop {
            cropViewController.imageCropFrame = currentCrop
        }
        cropViewController.delegate = self

        // Without this, there is a transition error and the presented navigation controller is removed
        // https://github.com/TimOliver/TOCropViewController/issues/365
        cropViewController.modalTransitionStyle = .crossDissolve
        cropViewController.transitioningDelegate = nil

        presentedNavigation.present(cropViewController, animated: true, completion: nil)
    }
}

extension CreateSentenceCoordinator: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        currentCrop = cropRect
        croppedImage = image
        createSentenceViewController?.setImage(image)

        cropViewController.dismiss(animated: true, completion: nil)
    }
}
