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
                page.pageData.append(data)
            }
        })

        return page
    }

    func nextPage(currentPage: UIViewController) -> UIViewController? {
        guard let currentPage = currentPage as? PageViewController else {
            return PageViewController()
        }

        let index = currentPage.page + 1
        guard index < self.mangaReader.fileEntries.count else {
            // End of manga
            return nil
        }

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

        return self.createPage(index: index, doublePaged: currentPage.doublePaged, delegate: currentPage.delegate, fullScreen: currentPage.fullScreen)
    }
}
