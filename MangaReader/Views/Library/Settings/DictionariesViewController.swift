//
//  DictionariesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import UIKit

protocol DictionariesViewControllerDelegate: AnyObject {
    func didSelectAdd(_ dictionariesViewController: DictionariesViewController)
    func didSelectDelete(_ dictionariesViewController: DictionariesViewController, dictionary: Dictionary)
}

class DictionariesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingOverlay: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var importingInfoLabel: UILabel!

    private var dictionaries: [Dictionary]
    private weak var delegate: DictionariesViewControllerDelegate?
    init(dictionaries: [Dictionary], delegate: DictionariesViewControllerDelegate) {
        self.dictionaries = dictionaries
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureNavBar()
        configureLoadingView()
    }

    func setDictionaries(_ dictionaries: [Dictionary]) {
        self.dictionaries = dictionaries
        tableView.reloadData()
    }

    func startLoading(isDelete: Bool = false) {
        view.isUserInteractionEnabled = false
        progressView.progress = 0
        loadingOverlay.alpha = 0
        loadingOverlay.isHidden = false
        importingInfoLabel.text = isDelete ? "Deleting dictionary... (This may take a couple of minutes)" : "Loading dictionary..."
        progressView.isHidden = isDelete
        UIView.animate(withDuration: 0.2) {
            self.loadingOverlay.alpha = 1
        }
    }

    func endLoading() {
        view.isUserInteractionEnabled = true
        self.loadingOverlay.alpha = 1
        UIView.animate(withDuration: 0.2) {
            self.loadingOverlay.alpha = 0
        } completion: { _ in
            self.loadingOverlay.isHidden = true
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dictionaryCell")
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        title = "Manage dictionaries"
    }

    private func configureLoadingView() {
        loadingOverlay.layer.cornerRadius = 15
    }

    @objc func add() {
        delegate?.didSelectAdd(self)
    }
}

extension DictionariesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dictionaryCell")!

        cell.textLabel?.text = dictionaries[indexPath.row].title

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if dictionaries.count > 1 {
                delegate?.didSelectDelete(self, dictionary: dictionaries[indexPath.row])
            } else {
                let alert = UIAlertController(title: "Are you sure?", message: "You only have one dictionary. Deleting it will make the app show no results when searching a definition", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.delegate?.didSelectDelete(self, dictionary: self.dictionaries[indexPath.row])
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
}
