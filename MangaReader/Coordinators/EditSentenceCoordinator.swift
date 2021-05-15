//
//  CreateSentenceCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import Foundation
import CropViewController

protocol EditSentenceCoordinatorDelegate: AnyObject {
    func didCancel(_ createSentenceCoordinator: EditSentenceCoordinator)
    func didEnd(_ createSentenceCoordinator: EditSentenceCoordinator, image: UIImage?, sentence: String, definition: String)
}

class EditSentenceCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()

    private var presentedNavigation: Navigable!
    private var currentCrop: CGRect?
    private var croppedImage: UIImage?
    private var createSentenceViewController: CreateSentenceViewController?

    private let navigation: Navigable
    private let image: UIImage?
    private let sentence: String
    private let definition: String
    private weak var delegate: EditSentenceCoordinatorDelegate?
    init(navigation: Navigable, image: UIImage?, sentence: String, definition: String, delegate: EditSentenceCoordinatorDelegate?) {
        self.navigation = navigation
        self.image = image
        self.sentence = sentence
        self.definition = definition
        self.delegate = delegate
    }

    convenience init(navigation: Navigable, sentence: Sentence, delegate: EditSentenceCoordinatorDelegate) {
        self.init(navigation: navigation, image: sentence.image, sentence: sentence.sentence, definition: sentence.definition, delegate: delegate)
    }

    func start() {
        let createSentenceViewController = CreateSentenceViewController(image: image, sentence: sentence, definition: definition, delegate: self)
        presentedNavigation = createPresentableNavigation()
        presentedNavigation.setViewControllers([createSentenceViewController], animated: false)

        navigation.present(presentedNavigation, animated: true, completion: nil)
        self.createSentenceViewController = createSentenceViewController
    }

    func createPresentableNavigation() -> Navigable {
        return UINavigationController()
    }
}

extension EditSentenceCoordinator: CreateSentenceViewControllerDelegate {
    func cancel(_ createSentenceViewController: CreateSentenceViewController) {
        navigation.dismiss(animated: true, completion: nil)
        delegate?.didCancel(self)
    }

    func save(_ createSentenceViewController: CreateSentenceViewController, sentence: String, definition: String) {
        navigation.dismiss(animated: true, completion: nil)
        delegate?.didEnd(self, image: croppedImage ?? image, sentence: sentence, definition: definition)
    }

    func editImage(_ createSentenceViewController: CreateSentenceViewController) {
        guard let image = image else { return }
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

extension EditSentenceCoordinator: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        currentCrop = cropRect
        croppedImage = image
        createSentenceViewController?.setImage(image)

        cropViewController.dismiss(animated: true, completion: nil)
    }
}
