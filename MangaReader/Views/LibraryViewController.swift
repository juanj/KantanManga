//
//  LibraryViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol LibraryViewControllerDelegate: AnyObject {
    func didSelectAdd(_ libraryViewController: LibraryViewController)
    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga)
    func didSelectDeleteManga(_ libraryViewController: LibraryViewController, manga: Manga)
}

class LibraryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: LibraryViewControllerDelegate?
    var mangas = [Manga]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Library"
        self.configureCollectionView()
        self.configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(UINib.init(nibName: "MangaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")

        let deleteMenuItem = UIMenuItem(title: "Delete", action: NSSelectorFromString("deleteCollectionCell"))
        UIMenuController.shared.menuItems = [deleteMenuItem]
    }

    func configureNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(add))
        self.navigationItem.leftBarButtonItem = addButton
    }

    @objc func add() {
        self.delegate?.didSelectAdd(self)
    }
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mangas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MangaCell", for: indexPath) as! MangaCollectionViewCell // swiftlint:disable:this force_cast

        let manga = self.mangas[indexPath.row]
        if let data = manga.coverImage {
            cell.coverImageView.image = UIImage(data: data)
        }
        cell.pageLabel.text = "\(manga.currentPage)/\(manga.totalPages)"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let manga = self.mangas[indexPath.row]
        self.delegate?.didSelectManga(self, manga: manga)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
    }

    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false//return action == NSSelectorFromString("deleteCollectionCell")
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        self.delegate?.didSelectDeleteManga(self, manga: self.mangas[indexPath.row])
    }
}
