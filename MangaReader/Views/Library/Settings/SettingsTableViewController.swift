//
//  SettingsTableViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 27/06/20.
//

import Foundation
import SwiftUI

protocol SettingsTableViewControllerDelegate: AnyObject {
    func didSelectAbout(_ settingsTableViewController: SettingsTableViewController)
}

class SettingsTableViewController: UITableViewController {
    enum InfoSection: String, CaseIterable {
        case about
    }

    let sections = [
        InfoSection.allCases
    ]

    private weak var delegate: SettingsTableViewControllerDelegate?
    init(delegate: SettingsTableViewControllerDelegate) {
        self.delegate = delegate
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        configureTableView()
    }

    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.tableFooterView = UIView()
    }
}

extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeueCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") {
            cell = dequeueCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsCell")
        }

        cell.textLabel?.text = sections[indexPath.section][indexPath.row].rawValue.capitalized
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell.accessoryView?.tintColor = .label

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section][indexPath.row]
        if selectedItem == .about {
            delegate?.didSelectAbout(self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
