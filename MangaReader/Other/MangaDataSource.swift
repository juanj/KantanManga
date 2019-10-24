//
//  MangaDataSource.swift
//  MangaReader
//
//  Created by Juan on 2/21/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

class MangaDataSource {
    let mangaReader: CBZReader
    let manga: Manga

    init?(manga: Manga) {
        self.manga = manga
        guard let path = self.manga.filePath else {
            return nil
        }
        do {
            self.mangaReader = try CBZReader(fileName: path)
            self.preloadNextPages(start: Int(manga.currentPage), pages: 10)
            self.preloadPreviousPages(start: Int(manga.currentPage), pages: 10)
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
        self.mangaReader.readEntityAt(index: page.page, { (data) in
            if let data = data {
                DispatchQueue.main.async {
                    page.pageData.append(data)
                }
            }
        })

        return page
    }

    func nextPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController else {
            return PageViewController()
        }

        let index = currentPage.page + 1
        guard index < self.mangaReader.numberOfPages else {
            // End of manga
            return nil
        }
        self.preloadNextPages(start: index + 10, pages: 2)
        return self.createPage(index: index, doublePaged: currentPage.doublePaged, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
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
        self.preloadPreviousPages(start: index - 10, pages: 2)
        return self.createPage(index: index, doublePaged: currentPage.doublePaged, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
    }

    private func preloadNextPages(start: Int, pages: Int) {
        let startPage = min(start, Int(self.manga.totalPages))
        let endPage = min(startPage + pages, Int(self.manga.totalPages))
        for page in startPage...endPage {
            self.mangaReader.readEntityAt(index: page, nil)
        }
    }

    private func preloadPreviousPages(start: Int, pages: Int) {
        let startPage = max(start, 0)
        let endPage = max(startPage - pages, 0)
        for page in endPage...startPage {
            self.mangaReader.readEntityAt(index: page, nil)
        }
    }
}
