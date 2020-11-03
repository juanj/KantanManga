//
//  ViewerSettingsViewController.swift
//  Kantan-Manga
//
//  Created by Juan on 3/11/20.
//

import UIKit

class ViewerSettingsViewController: UIViewController {
    @IBOutlet weak var settingsTableView: UITableView!

    override func viewDidLoad() {
        title = "Viewer Settings"
        settingsTableView.register(UINib(nibName: "ToggleTableViewCell", bundle: nil), forCellReuseIdentifier: "toggleSettingsCell")
        settingsTableView.dataSource = self
    }
}

extension ViewerSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Page Numbers"
        case 1:
            return "Pages"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleSettingsCell") as! ToggleTableViewCell // swiftlint:disable:this force_cast
            cell.textLabel?.text = "Show page numbers"
            cell.switchControl.isOn = true
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleSettingsCell") as! ToggleTableViewCell // swiftlint:disable:this force_cast
            cell.textLabel?.text = "Double paged"
            cell.switchControl.isOn = true
            return cell
        default:
            fatalError("\(indexPath.section) section is not implemented")
        }
    }
}
