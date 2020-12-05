//
//  DictionariesViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 5/12/20.
//

import UIKit

class DictionariesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var dictionaries: [DictionaryIndex]
    init(dictionaries: [DictionaryIndex]) {
        self.dictionaries = dictionaries
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dictionaryCell")
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
