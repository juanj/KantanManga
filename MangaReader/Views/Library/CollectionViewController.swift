//
//  CollectionViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 15/09/20.
//

import UIKit

protocol CollectionViewControllerDelegate: AnyObject {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect)
}

class CollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private weak var delegate: CollectionViewControllerDelegate?
    private var collection: MangaCollectionable
    private let sourcePoint: CGPoint
    private var animating = true

    init(delegate: CollectionViewControllerDelegate, collection: MangaCollectionable, sourcePoint: CGPoint) {
        self.delegate = delegate
        self.collection = collection
        self.sourcePoint = sourcePoint
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = collection.name
        configureCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if animating {
            animating = false
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        } else {
            collectionView.reloadData()
        }
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        collectionView.register(UINib(nibName: "MangaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")
        collectionView.collectionViewLayout = ExpandCollectionLayout(originPoint: sourcePoint)
    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.mangas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MangaCell", for: indexPath) as! MangaCollectionViewCell // swiftlint:disable:this force_cast

        let manga = collection.mangas[indexPath.row]
        manga.loadCoverImage()
        if let image = manga.coverImage {
            cell.coverImageView.image = image
        }
        cell.pageLabel.text = "\(manga.currentPage)/\(manga.totalPages)"
        if animating {
            if indexPath.row < 3 {
                cell.layer.zPosition = 1000 + CGFloat(3 - indexPath.row)
            }
            cell.center = sourcePoint
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MangaCollectionViewCell else { return }
        let frame = cell.convert(cell.coverImageView.frame, to: view)
        let manga = collection.mangas[indexPath.row]
        delegate?.didSelectManga(self, manga: manga, cellFrame: frame)
    }
}
