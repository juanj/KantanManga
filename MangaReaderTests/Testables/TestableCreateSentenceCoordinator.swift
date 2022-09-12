//
//  TestableEditSentenceCoordinator.swift
//  Kantan-MangaTests
//
//  Created by Juan on 20/02/21.
//

@testable import Kantan_Manga

class TestableEditSentenceCoordinator: EditSentenceCoordinator {
    var presentableNavigable: Navigable?
    override func createPresentableNavigation() -> Navigable {
        if let navigation = presentableNavigable {
            return navigation
        } else {
            return super.createPresentableNavigation()
        }
    }
}
