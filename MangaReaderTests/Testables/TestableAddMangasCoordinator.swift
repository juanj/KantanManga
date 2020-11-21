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
        return presentableNavigable ?? FakeNavigation()
    }
}
