//
//  FakeSelectCollectionTableViewControllerDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 19/11/20.
//

@testable import Kantan_Manga

// swiftlint:disable:next type_name
class FakeSelectCollectionTableViewControllerDelegate: SelectCollectionTableViewControllerDelegate {
    func selectCollection(_ selectCollectionTableViewController: SelectCollectionTableViewController, collection: MangaCollection) {}
    func addCollection(_ selectCollectionTableViewController: SelectCollectionTableViewController, name: String) {}
}
