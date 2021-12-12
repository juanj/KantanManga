//
//  SentencesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 21/02/21.
//

import UIKit

protocol SentencesViewControllerDelegate: AnyObject {
    func refresh(_ sentencesViewController: SentencesViewController)
    func didSelectSentence(_ sentencesViewController: SentencesViewController, sentence: Sentence)
    func didSelectSyncSentences(_ sentencesViewController: SentencesViewController)
    func didSelectConfigureAnki(_ sentencesViewController: SentencesViewController)
}

class SentencesViewController: UIViewController {
    private var tableView = UITableView(frame: .zero, style: .plain)

    var sentences: [Sentence] {
        didSet {
            refresh()
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

    func refresh() {
        tableView.reloadData()
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
        let syncButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(syncSentences))
        let config = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(configureAnki))
        navigationItem.leftBarButtonItem = syncButton
        navigationItem.rightBarButtonItem = config
    }

    @objc func syncSentences() {
        delegate?.didSelectSyncSentences(self)
    }

    @objc func configureAnki() {
        delegate?.didSelectConfigureAnki(self)
    }
}

extension SentencesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        delegate?.didSelectSentence(self, sentence: sentences[indexPath.row])
    }
}

extension SentencesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "sentenceCellId") else {
            fatalError("Failed to dequeue cell with reusable identifier sentenceCellId")
        }
        let sentence = sentences[indexPath.row]

        let displayText: String
        if !sentence.sentence.trimmingCharacters(in: .whitespaces).isEmpty {
            displayText = sentence.sentence
        } else {
            displayText = sentence.word
        }

        cell.textLabel?.text = displayText

        return cell
    }
}
