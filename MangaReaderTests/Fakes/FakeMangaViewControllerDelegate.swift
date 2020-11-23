//
//  FakeMangaViewControllerDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 23/11/20.
//

@testable import Kantan_Manga

class FakeMangaViewControllerDelegate: MangaViewControllerDelegate {
    func didTapPage(_ mangaViewController: MangaViewController, pageViewController: PageViewController) {}
    func back(_ mangaViewController: MangaViewController) {}
    func didSelectSectionOfImage(_ mangaViewController: MangaViewController, image: UIImage) {}
    func didTapSettings(_ mangaViewController: MangaViewController) {}
    func pageDidChange(_ mangaViewController: MangaViewController, manga: Manga, newPage: Int) {}
}
