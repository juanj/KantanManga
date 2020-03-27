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
}

class AddMangaViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var collectionTextField: AutoCompleteTextField!
    @IBOutlet weak var mangaImageView: UIImageView!

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
        configureMangaImageView()
        nameTextField.addTarget(self, action: #selector(resetTextField), for: .editingChanged)
        collectionTextField.autoCompleteDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let resultSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.preferredContentSize = resultSize
    }

    func setFile(path: String) {
        let fileName = (path as NSString).lastPathComponent
        guard let reader = try? CBZReader(fileName: fileName) else {
            print("Error creating CBZReader")
            return
        }
        self.fileName = fileName
        reader.readFirstEntry { (data) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.mangaImageView.image = UIImage(data: data)
            }
        }
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    private func configureMangaImageView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectManga))
        mangaImageView.isUserInteractionEnabled = true
        mangaImageView.addGestureRecognizer(tap)
    }

    @objc func cancel() {
        delegate?.cancel(addMangaViewController: self)
    }

    @objc func save() {
        guard let name = nameTextField.text, !name.isEmpty else {
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.layer.borderWidth = 1
            return
        }
        guard let fileName = self.fileName else {
            mangaImageView.layer.borderWidth = 1
            mangaImageView.layer.borderColor = UIColor.red.cgColor
            return
        }
        delegate?.save(addMangaViewController: self, name: name, path: fileName, collection: nil)
    }

    @objc func selectManga() {
        mangaImageView.layer.borderWidth = 0
        delegate?.selectManga(addMangaViewController: self)
    }

    @objc func resetTextField() {
        nameTextField.layer.borderWidth = 0
    }
}

extension AddMangaViewController: AutoCompleteTextFieldDelegate {
    func autoCompleteResultForText(autoCompleteTextField: AutoCompleteTextField, text: String) -> String? {
        guard let results = CoreDataManager.sharedManager.searchCollectionsStartWith(name: text) else {
            return nil
        }
        for result in results {
            if result.name == text {
                continue
            } else {
                return result.name
            }
        }
        return nil
    }

    func didSelectText(autoCompleteTextField: AutoCompleteTextField, text: String) {
        
    }
}
