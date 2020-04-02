//
//  SelectCollectionTableViewController.swift
//  MangaReader
//
//  Created by Juan on 2/04/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import UIKit

protocol SelectCollecionTableViewControllerDelegate: AnyObject {
    func selectCollection(selectCollectionTableViewController: SelectCollectionTableViewController, collection: MangaCollection)
    func addCollection(selectCollectionTableViewController: SelectCollectionTableViewController, name: String)
}

class SelectCollectionTableViewController: UITableViewController {
    private weak var delegate: SelectCollecionTableViewControllerDelegate?
    private let collections: [MangaCollection]

    init(delegate: SelectCollecionTableViewControllerDelegate, collections: [MangaCollection]) {
        self.delegate = delegate
        self.collections = collections
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureTableView()
    }

    private func configureNavigationBar() {
        title = "Collections"
    }

    private func configureTableView() {
        let nib = UINib(nibName: "NewCollectionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NewCollectionCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
    }

    @objc func add() {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return collections.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewCollectionCell", for: indexPath) as! NewCollectionTableViewCell // swiftlint:disable:this force_cast
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = collections[indexPath.row].name
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = collections[indexPath.row]
        delegate?.selectCollection(selectCollectionTableViewController: self, collection: collection)
    }
}

extension SelectCollectionTableViewController: NewCollectionTableViewCellDelegate {
    func didEnterName(name: String) {
        delegate?.addCollection(selectCollectionTableViewController: self, name: name)
    }
}
