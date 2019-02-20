//
//  LibraryViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mangas = [Manga]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Library"
        self.configureCollectionView()
    }
    
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib.init(nibName: "MangaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")
    }
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mangas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MangaCell", for: indexPath) as! MangaCollectionViewCell
        
        let manga = self.mangas[indexPath.row]
        if let data = manga.coverImage {
            cell.coverImageView.image = UIImage(data: data)
        }
        cell.pageLabel.text = "\(manga.currentPage)/\(manga.totalPages)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
    }
}
