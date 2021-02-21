//
//  CreateAnkiCardCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import Foundation
import CropViewController

protocol CreateAnkiCardCoordinatorDelegate: AnyObject {
    func didEnd(_ createAnkiCardCoordinator: CreateAnkiCardCoordinator)
}

class CreateAnkiCardCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private var presentedNavigation: Navigable!
    private var currentCrop: CGRect?
    private var croppedImage: UIImage?
    private var createAnkiCardViewController: CreateAnkiCardViewController?

    private let navigation: Navigable
    private let image: UIImage
    private let sentence: String
    private let term: Term
    private weak var delegate: CreateAnkiCardCoordinatorDelegate?
    init(navigation: Navigable, image: UIImage, sentence: String, term: Term, delegate: CreateAnkiCardCoordinatorDelegate?) {
        self.navigation = navigation
        self.image = image
        self.sentence = sentence
        self.term = term
        self.delegate = delegate
    }

    func start() {
        let createAnkiCardViewController = CreateAnkiCardViewController(image: image, sentence: sentence, term: term, delegate: self)
        presentedNavigation = createPresentableNavigation()
        presentedNavigation.setViewControllers([createAnkiCardViewController], animated: false)

        navigation.present(presentedNavigation, animated: true, completion: nil)
        self.createAnkiCardViewController = createAnkiCardViewController
    }

    func createPresentableNavigation() -> Navigable {
        return UINavigationController()
    }
}

extension CreateAnkiCardCoordinator: CreateAnkiCardViewControllerDelegate {
    func cancel(_ createAnkiCardViewController: CreateAnkiCardViewController) {
        navigation.dismiss(animated: true, completion: nil)
        delegate?.didEnd(self)
    }

    func save(_ createAnkiCardViewController: CreateAnkiCardViewController) {

    }

    func editImage(_ createAnkiCardViewController: CreateAnkiCardViewController) {
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

extension CreateAnkiCardCoordinator: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        currentCrop = cropRect
        croppedImage = image
        createAnkiCardViewController?.setImage(image)

        cropViewController.dismiss(animated: true, completion: nil)
    }
}
