//
//  DictionariesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import UIKit

protocol DictionariesViewControllerDelegate: AnyObject {
    func didSelectAdd(_ dictionariesViewController: DictionariesViewController)
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

    func startLoading() {
        view.isUserInteractionEnabled = false
        progressView.progress = 0
        loadingOverlay.alpha = 0
        loadingOverlay.isHidden = false
        importingInfoLabel.text = "Loading dictionary..."
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
}
