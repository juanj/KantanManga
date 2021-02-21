//
//  SentencesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 21/02/21.
//

import UIKit

protocol SentencesViewControllerDelegate: AnyObject {
    func refresh(_ sentencesViewController: SentencesViewController)
}

class SentencesViewController: UIViewController {
    private var tableView = UITableView(frame: .zero, style: .plain)

    var sentences: [Sentence] {
        didSet {
            tableView.reloadData()
        }
    }
    private weak var delegate: SentencesViewControllerDelegate?

    init(sentences: [Sentence], delegate: SentencesViewControllerDelegate) {
        self.sentences = sentences
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.refresh(self)
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addConstraintsTo(view)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sentenceCellId")
    }

    private func configureNavigationBar() {
        title = "Sentences"
    }
}

extension SentencesViewController: UITableViewDelegate {}

extension SentencesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "sentenceCellId") else {
            fatalError("Failed to dequeue cell with reusable identifier sentenceCellId")
        }

        cell.textLabel?.text = sentences[indexPath.row].sentence

        return cell
    }
}
