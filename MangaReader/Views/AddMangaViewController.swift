//
//  AddMangaViewController.swift
//  MangaReader
//
//  Created by Juan on 30/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

protocol AddMangaViewControllerDelegate: AnyObject {
    func cancel(addMangaViewController: AddMangaViewController)
    func save(addMangaViewController: AddMangaViewController, name: String, path: String, collection: MangaCollection?)
    func selectManga(addMangaViewController: AddMangaViewController)
    func selectCollection(addMangaViewController: AddMangaViewController)
}

class AddMangaViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var selectFileButton: UIButton!
    @IBOutlet weak var selectCollectionButton: UIButton!
    private weak var delegate: AddMangaViewControllerDelegate?
    private var fileName: String?

    init(delegate: AddMangaViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.preferredContentSize = CGSize(width: 400, height: 188)
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        title = "Add manga"
    }

    @objc func cancel() {
        delegate?.cancel(addMangaViewController: self)
    }

    @IBAction func selectFile() {
        delegate?.selectManga(addMangaViewController: self)
    }

    @IBAction func selectCollection() {
        delegate?.selectCollection(addMangaViewController: self)
    }

    @objc func save() {
        /*guard let name = nameTextField.text, !name.isEmpty else {
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.layer.borderWidth = 1
            return
        }
        guard let fileName = self.fileName else {
            mangaImageView.layer.borderWidth = 1
            mangaImageView.layer.borderColor = UIColor.red.cgColor
            return
        }
        delegate?.save(addMangaViewController: self, name: name, path: fileName, collection: nil)*/
    }
}
