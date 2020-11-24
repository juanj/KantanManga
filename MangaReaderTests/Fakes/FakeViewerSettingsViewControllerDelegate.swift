//
//  FakeViewerSettingsViewControllerDelegate.swift
//  Kantan-MangaTests
//
//  Created by Juan on 24/11/20.
//

@testable import Kantan_Manga

class FakeViewerSettingsViewControllerDelegate: ViewerSettingsViewControllerDelegate {
    func updatePagesSetting(_ viewerSettingsViewController: ViewerSettingsViewController, setting: ViewerPagesSettings, newValue: SettingValue) {}
    func updatePageNumbersSetting(_ viewerSettingsViewController: ViewerSettingsViewController, setting: ViewerPageNumberSettings, newValue: SettingValue) {}
}
