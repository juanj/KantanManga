//
//  FakeSettingsTableViewControllerDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 25/11/20.
//

@testable import Kantan_Manga

class FakeSettingsTableViewControllerDelegate: SettingsTableViewControllerDelegate {
    func didSelectAbout(_ settingsTableViewController: SettingsTableViewController) {}
    func didSelectLoadDemo(_ settingsTableViewController: SettingsTableViewController) {}
    func didSelectAcknowledgments(_ settingsTableViewController: SettingsTableViewController) {}
    func didSelectClose(_ settingsTableViewController: SettingsTableViewController) {}
    func didSelectDictionaries(_ settingsTableViewController: SettingsTableViewController) {}
}
