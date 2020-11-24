//
//  TestableAddMangasCoordinator.swift
//  Kantan-MangaTests
//
//  Created by Juan on 21/11/20.
//

@testable import Kantan_Manga

class TestableAddMangasCoordinator: AddMangasCoordinator {
    var presentableNavigable: Navigable?
    override func createPresentableNavigation() -> Navigable {
        if let navigation = presentableNavigable {
            return navigation
        } else {
            return super.createPresentableNavigation()
        }
    }
}
