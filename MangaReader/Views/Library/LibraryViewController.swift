//
//  LibraryViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol LibraryViewControllerDelegate: AnyObject {
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem)
    func didSelectSettings(_ libraryViewController: LibraryViewController)
    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, rotations: [CGAffineTransform])
    func didSelectDeleteCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable)
    func didSelectRenameCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable, name: String?)
    func didSelectLoadDemoManga(_ libraryViewController: LibraryViewController)
}

class LibraryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var hideIndexPath: IndexPath?
    var fadeImages: Bool = false

    private weak var delegate: LibraryViewControllerDelegate?
    private var collections = [MangaCollectionable]()
    private var showOnboarding: Bool
    private let rotations: [CGAffineTransform]

    init(delegate: LibraryViewControllerDelegate, collections: [MangaCollectionable], showOnboarding: Bool = false) {
        self.delegate = delegate
        self.collections = collections
        self.showOnboarding = showOnboarding
        rotations = [CGAffineTransform(rotationAngle: -0.05),
                     CGAffineTransform(rotationAngle: 0.07),
                     CGAffineTransform(rotationAngle: 0.03)]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Library"
        configureCollectionView()
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        if showOnboarding {
            showOnboarding = false
            present(OnboardingViewController(delegate: self), animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func setCollections(collections: [MangaCollectionable]) {
        self.collections = collections
        self.collectionView.reloadData()
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

        collectionView.register(UINib(nibName: "MangaCollectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        collectionView.collectionViewLayout = layout
    }

    private func configureNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(add(button:)))
        navigationItem.leftBarButtonItem = addButton

        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settings(button:)))
        navigationItem.rightBarButtonItem = settingsButton
    }

    private func heightForImageWith(maxWidth: CGFloat, maxHeight: CGFloat, image: UIImage) -> CGFloat {
        let widthScale = image.size.width / maxWidth
        let heightScale = image.size.height / maxHeight

        if widthScale > heightScale {
            return (image.size.height / widthScale)
        } else {
            return maxHeight
        }
    }

    @objc func add(button: UIBarButtonItem) {
        delegate?.didSelectAdd(self, button: button)
    }

    @objc func settings(button: UIBarButtonItem) {
        delegate?.didSelectSettings(self)
    }
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MangaCell", for: indexPath) as! MangaCollectionCollectionViewCell // swiftlint:disable:this force_cast

        let collection = collections[indexPath.row]
        let mangas = collection.mangas.prefix(3)
        mangas.forEach { $0.loadCoverImage() }
        let images = mangas.map { $0.coverImage ?? UIImage() }
        cell.setImages(images)
        cell.nameLabel.text = collection.name
        cell.rotations = rotations

        if indexPath == hideIndexPath {
            // Images start hidden
            cell.imageViews.forEach { $0.alpha = 0 }

            // Name starts hidden an fades in
            cell.nameLabel.alpha = 0
            UIView.animate(withDuration: 0.5) {
                cell.nameLabel.alpha = 1
                if self.fadeImages {
                    cell.imageViews.forEach { $0.alpha = 1 }
                }
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCollection(self, collection: collections[indexPath.row], rotations: rotations)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collection = collections[indexPath.row]
        let identifier = NSNumber(value: indexPath.row)
        let configuration = UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this collection and all its content?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.delegate?.didSelectDeleteCollection(self, collection: collection)
                }))
                self.present(alert, animated: true, completion: nil)
            }

            let rename = UIAction(title: "Rename collection", image: UIImage(systemName: "pencil")) { _ in
                let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { _ in
                    self.delegate?.didSelectRenameCollection(self, collection: collection, name: alert.textFields?.first?.text)
                }))

                alert.addTextField { textField in
                    textField.placeholder = "Collection name"
                    textField.text = collection.name
                }
                self.present(alert, animated: true, completion: nil)
            }
            return UIMenu(title: collection.name ?? "", image: nil, identifier: nil, children: [rename, delete])
        }

        return configuration
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return previewFor(configuration)
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return previewFor(configuration)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }

    private func previewFor(_ configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let index = configuration.identifier as? NSNumber,
              let cell = collectionView.cellForItem(at: IndexPath(row: index.intValue, section: 0)) as? MangaCollectionCollectionViewCell else { return nil }

        let path = UIBezierPath()
        for image in cell.imageViews where image.image != nil {
            let newPath = UIBezierPath(roundedRect: image.imageView.frame, cornerRadius: 8)
            newPath.apply(CGAffineTransform(translationX: -(image.frame.width / 2), y: -(image.frame.height / 2)))
            newPath.apply(image.transform)
            newPath.apply(CGAffineTransform(translationX: image.frame.width / 2, y: image.frame.height / 2))
            path.append(newPath)
        }
        let parameters = UIPreviewParameters()
        parameters.visiblePath = path
        parameters.backgroundColor = .clear
        let preview = UITargetedPreview(view: cell.container, parameters: parameters)
        return preview
    }
}

extension LibraryViewController: OnboardingViewControllerDelegate {
    func didSelectLoadManga(_ onboardingViewController: OnboardingViewController) {
        delegate?.didSelectLoadDemoManga(self)
    }

    func didSelectNotNow(_ onboardingViewController: OnboardingViewController) {
        dismiss(animated: true, completion: nil)
    }
}
