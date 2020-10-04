//
//  CollectionViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 15/09/20.
//

import UIKit

protocol CollectionViewControllerDelegate: AnyObject {
    func didSelectManga(_ collectionViewController: CollectionViewController, manga: Manga, cellFrame: CGRect)
    func didSelectDeleteManga(_ collectionViewController: CollectionViewController, manga: Manga)
    func didSelectRenameManga(_ collectionViewController: CollectionViewController, manga: Manga, name: String?)
    func didSelectMoveManga(_ collectionViewController: CollectionViewController, manga: Manga)
}

class CollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private weak var delegate: CollectionViewControllerDelegate?
    private var collection: MangaCollectionable
    private let sourcePoint: CGPoint
    private let initialRotations: [CGAffineTransform]
    var animating = true

    init(delegate: CollectionViewControllerDelegate, collection: MangaCollectionable, sourcePoint: CGPoint, initialRotations: [CGAffineTransform]) {
        self.delegate = delegate
        self.collection = collection
        self.sourcePoint = sourcePoint
        self.initialRotations = initialRotations
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animating = false
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        collectionView.register(UINib(nibName: "MangaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")
    }

    func closeAnimation(duration: TimeInterval) {
        guard let cells = collectionView.visibleCells as? [MangaCollectionViewCell] else { return }
        var offsetSourcePoint = sourcePoint
        offsetSourcePoint.y += collectionView.contentOffset.y + collectionView.contentInset.top
        for cell in cells {
            UIView.animate(withDuration: duration) {
                cell.center = offsetSourcePoint
                cell.pageLabel.alpha = 0

                if let indexPath = self.collectionView.indexPath(for: cell) {
                    if indexPath.row > 2 {
                        cell.alpha = 0
                    } else {
                        cell.coverImageView.transform = self.initialRotations[indexPath.row]
                    }
                }
            }
        }
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
        cell.pageLabel.text = "\(manga.currentPage + 1)/\(manga.totalPages)"
        if indexPath.row < 3 {
            cell.layer.zPosition = 1000 + CGFloat(3 - indexPath.row)
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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard animating else { return }
        guard let cell = cell as? MangaCollectionViewCell else { return }
        let oldCenter = cell.center
        cell.pageLabel.alpha = 0
        cell.center = sourcePoint
        if indexPath.row > 2 {
            cell.alpha = 0
        } else {
            cell.coverImageView.transform = initialRotations[indexPath.row]
        }
        UIView.animate(withDuration: 0.5) {
            cell.coverImageView.transform = .identity
            cell.center = oldCenter
            cell.pageLabel.alpha = 1
            cell.alpha = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let manga = collection.mangas[indexPath.row]
        let identifier = NSNumber(value: indexPath.row)
        let configuration = UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { _ in
                let alert = UIAlertController(title: "Delete", message: "Are you want to delete \(manga.name ?? "this manga")?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.delegate?.didSelectDeleteManga(self, manga: manga)
                }))
                self.present(alert, animated: true, completion: nil)
            }

            let rename = UIAction(title: "Rename", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil) { _ in
                let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { _ in
                    self.delegate?.didSelectRenameManga(self, manga: manga, name: alert.textFields?.first?.text)
                }))

                alert.addTextField { textField in
                    textField.placeholder = "Manga name"
                    textField.text = manga.name
                }
                self.present(alert, animated: true, completion: nil)
            }

            let move = UIAction(title: "Move to collection", image: UIImage(systemName: "arrow.right.arrow.left.square.fill"), identifier: nil, discoverabilityTitle: nil) { _ in
                self.delegate?.didSelectMoveManga(self, manga: manga)
            }
            return UIMenu(title: manga.name ?? "", image: nil, identifier: nil, children: [rename, move, delete])
        }

        return configuration
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return previewFor(configuration)
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return previewFor(configuration)
    }

    private func previewFor(_ configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let index = configuration.identifier as? NSNumber else { return nil }
        let indexPath = IndexPath(row: index.intValue, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? MangaCollectionViewCell, let image = cell.coverImageView.subviews.first else { return nil }
        return UITargetedPreview(view: image)
    }
}
