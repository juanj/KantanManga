//
//  MangaDataSource.swift
//  MangaReader
//
//  Created by Juan on 2/21/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

class MangaDataSource {
    let mangaReader: Reader
    let manga: Manga

    private var cache = [Int: UIImage]()

    init?(manga: Manga) {
        self.manga = manga
        guard let path = manga.filePath else {
            return nil
        }
        do {
            if path.lowercased().hasSuffix("cbz") || path.lowercased().hasSuffix("zip") {
                mangaReader = try CBZReader(fileName: path)
            } else {
                mangaReader = try CBRReader(fileName: path)
            }
            preloadPages()
        } catch {
            print("Error creating MangaDataSource")
            return nil
        }
    }

    func createPage(index: Int, doublePaged: Bool, delegate: PageViewControllerDelegate? = nil, fullScreen: Bool = false) -> PageViewController {
        let page = PageViewController()
        page.doublePaged = doublePaged
        page.page = index
        page.delegate = delegate
        page.fullScreen = fullScreen

        // Load image to page
        getImageForPage(index: index) { (image) in
            DispatchQueue.main.async {
                page.pageImage = image
            }
        }

        return page
    }

    func nextPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController else {
            return PageViewController()
        }

        let index = currentPage.page + 1
        guard index < mangaReader.numberOfPages else {
            // End of manga
            return nil
        }
        // preloadNextPages(start: index + 10, pages: 2)
        return createPage(index: index, doublePaged: currentPage.doublePaged, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
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
        // preloadPreviousPages(start: index - 10, pages: 2)
        return createPage(index: index, doublePaged: currentPage.doublePaged, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
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
                print(pageOffset)
                self.getImageForPage(index: currentPage - pageOffset) { (_) in
                    group.leave()
                }
            }
        }

    }

    private func getImageForPage(index: Int, callBack: @escaping  (UIImage?) -> Void) {
        if let imageInCache = cache[index] {
            callBack(imageInCache)
        } else {
            mangaReader.readEntityAt(index: index) { (data) in
                guard let data = data, let image = UIImage(data: data) else {
                    callBack(nil)
                    return
                }
                self.cache[index] = image
                callBack(image)
            }
        }
    }
}
