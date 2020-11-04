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
        settingsTableView.register(UINib(nibName: "NumberTableViewCell", bundle: nil), forCellReuseIdentifier: "numberSettingsCell")
        settingsTableView.dataSource = self
        settingsTableView.allowsSelection = false
    }
}

extension ViewerSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsSection.allCases[section].settings.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSection.allCases[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = SettingsSection.allCases[indexPath.section].settings[indexPath.row]
        switch setting.type {
        case .toggle(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleSettingsCell") as! ToggleTableViewCell // swiftlint:disable:this force_cast
            cell.label.text = setting.name
            cell.switchControl.isOn = value
            return cell
        case .number(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "numberSettingsCell") as! NumberTableViewCell // swiftlint:disable:this force_cast
            cell.label.text = setting.name
            cell.value = value
            return cell
        }
    }
}
