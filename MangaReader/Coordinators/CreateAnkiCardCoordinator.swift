//
//  CreateAnkiCardCoordinator.swift
//  Kantan-Manga
//
//  Created by Juan on 20/02/21.
//

import Foundation

protocol CreateAnkiCardCoordinatorDelegate: AnyObject {
    func didEnd(_ createAnkiCardCoordinator: CreateAnkiCardCoordinator)
}

class CreateAnkiCardCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    private var presentedNavigation: Navigable!

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
        presentedNavigation = createPresentableNavigation()
        presentedNavigation.setViewControllers([CreateAnkiCardViewController(image: image, sentence: sentence, term: term, delegate: self)], animated: false)

        navigation.present(presentedNavigation, animated: true, completion: nil)
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

    }
}
