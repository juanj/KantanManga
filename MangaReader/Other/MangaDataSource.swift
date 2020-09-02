//
//  MangaDataSource.swift
//  MangaReader
//
//  Created by Juan on 2/21/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

class MangaDataSource {
    private var mangaReader: Reader!
    private let manga: Manga

    private var cache = [Int: UIImage]() {
        didSet {
            // Only keep next 20 and previous 20 pages
            let currentPage = Int(manga.currentPage)
            cache = cache.filter { (element) -> Bool in
                element.key > (currentPage - 20) && element.key < (currentPage + 20)
            }
        }
    }
    private var queue = [(PageViewController, Int)]()

    init?(manga: Manga) {
        self.manga = manga
        guard let path = manga.filePath else {
            return nil
        }
        initReader(path: path)
    }

    private func initReader(path: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if path.lowercased().hasSuffix("cbz") || path.lowercased().hasSuffix("zip") {
                    self.mangaReader = try CBZReader(fileName: path)
                } else {
                    self.mangaReader = try CBRReader(fileName: path)
                }
            } catch let error {
                print("Error creating reader \(error.localizedDescription)")
            }
            self.clearQueue()
            self.preloadPages()
        }
    }

    func createPage(index: Int, doublePaged: Bool, offset: Bool = false, delegate: PageViewControllerDelegate? = nil, fullScreen: Bool = false) -> PageViewController {
        let page = PageViewController()
        page.doublePaged = doublePaged
        page.page = index
        page.delegate = delegate
        page.fullScreen = fullScreen
        page.offset = offset ? 1 : 0

        // Load image to page
        if mangaReader == nil {
            queue.append((page, index))
        } else {
            getImageForPage(index: index) { (image) in
                DispatchQueue.main.async {
                    page.pageImage = image
                }
            }
        }

        return page
    }

    func nextPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController, mangaReader != nil else {
            return PageViewController()
        }

        let index = currentPage.page + 1
        guard index < mangaReader.numberOfPages else {
            // End of manga
            return nil
        }

        getImageForPage(index: index + 10)
        return createPage(index: index, doublePaged: currentPage.doublePaged, offset: currentPage.offset == 1, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
    }

    func previousPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController else {
            return PageViewController()
        }

        let index = currentPage.page - 1
        guard index >= 0 else {
            // End of manga
            return nil
        }

        getImageForPage(index: index - 10)
        return createPage(index: index, doublePaged: currentPage.doublePaged, offset: currentPage.offset == 1, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
    }

    private func clearQueue() {
        for (page, index) in queue {
            getImageForPage(index: index) { (image) in
                DispatchQueue.main.async {
                    page.pageImage = image
                }
            }
        }
    }

    private func preloadPages() {
        let currentPage = Int(manga.currentPage)

        // Load current pages
        let serialQueue = DispatchQueue(label: "imagesPreload")
        let group = DispatchGroup()

        // Preload next 10 and previous 10 pages sequentialy
        let nextOffsets = 1...10
        let previouOffsets = (-10 ... -1).reversed()
        let offsets = zip(nextOffsets, previouOffsets).flatMap { [$0.0, $0.1] }

        group.enter()
        serialQueue.async {
            self.getImageForPage(index: currentPage) { (_) in
                group.leave()
            }
        }

        for pageOffset in offsets {
            serialQueue.async {
                group.wait()
                group.enter()
                self.getImageForPage(index: currentPage - pageOffset) { (_) in
                    group.leave()
                }
            }
        }

    }

    private func getImageForPage(index: Int, callBack: ((UIImage?) -> Void)? = nil) {
        guard mangaReader != nil else {
            callBack?(nil)
            return
        }

        if let imageInCache = cache[index] {
            callBack?(imageInCache)
        } else {
            mangaReader.readEntityAt(index: index) { (data) in
                guard let data = data, let image = UIImage(data: data) else {
                    callBack?(nil)
                    return
                }

                // Dictionaries are not thread safe.
                DispatchQueue.main.async {
                    self.cache[index] = image
                    callBack?(image)
                }
            }
        }
    }
}
