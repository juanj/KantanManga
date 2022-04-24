//
//  AnkiNamesListViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 18/09/21.
//

import UIKit

protocol AnkiNamesListViewControllerDelegate: AnyObject {
    func didSelectName(_ ankiNamesListViewController: AnkiNamesListViewController, name: String)
}

class AnkiNamesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let names: [String]
    private weak var delegate: AnkiNamesListViewControllerDelegate?

    init(names: [String], title: String, delegate: AnkiNamesListViewControllerDelegate) {
        self.names = names
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NameCell")
    }
}

extension AnkiNamesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell") else {
            preconditionFailure("Failed to dequeue cell with identifier NameCell")
        }

        cell.textLabel?.text = names[indexPath.row]

        return cell
    }
}

extension AnkiNamesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectName(self, name: names[indexPath.row])
    }
}
