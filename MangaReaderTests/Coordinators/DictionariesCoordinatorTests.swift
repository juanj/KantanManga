//
//  DictionariesCoordinatorTests.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import XCTest
@testable import Kantan_Manga

class DictionariesCoordinatorTests: XCTestCase {
    func testStart_withEmptyNavigationStack_pushesDictionariesViewController() {
        let mockNavigation = FakeNavigation()
        let dictionariesCoordinator = TestsFactories.createDictionariesCoordinator(navigable: mockNavigation)

        dictionariesCoordinator.start()

        XCTAssertNotNil(mockNavigation.viewControllers.last as? DictionariesViewController )
    }

    // MARK: DictionariesViewControllerDelegate
    func testDictionariesViewControllerDelegateDidSelectAdd_withEmptyNavigationStack_presentsUIDocumentPickerViewController() {
        let mockNavigation = FakeNavigation()
        let dictionariesCoordinator = TestsFactories.createDictionariesCoordinator(navigable: mockNavigation)

        dictionariesCoordinator.didSelectAdd(DictionariesViewController(dictionaries: [], delegate: FakeDictionariesViewControllerDelegate()))

        XCTAssertNotNil(mockNavigation.presentedViewController as? UIDocumentPickerViewController)
    }

    // MARK: UIDocumentPickerDelegate
    func testUIDocumentPickerDelegateDidPickDocumentsAt_withUrls_callsImportDictionaryOnDictionaryImporter() {
        let mockDecoder = FakeDictionaryDecoder()
        let dictionariesCoordinator = TestsFactories.createDictionariesCoordinator(decoder: mockDecoder)

        dictionariesCoordinator.documentPicker(UIDocumentPickerViewController(documentTypes: [], in: .import), didPickDocumentsAt: [URL(string: "file:///test.zip")!])

        print(mockDecoder.decodedDictionaries)
        XCTAssertTrue(mockDecoder.decodedDictionaries.contains { $0 == URL(string: "file:///test.zip")! })
    }
}
