//
//  SettingsSection.swift
//  Kantan-Manga
//
//  Created by Juan on 4/11/20.
//

import Foundation

enum SettingsSection: CaseIterable {
    case pageNumber, pages

    var title: String {
        switch self {
        case .pageNumber:
            return "Page Numbers"
        case .pages:
            return "Pages"
        }
    }

    var settings: [Setting] {
        switch self {
        case .pageNumber:
            return [
                Setting(name: "Show page numbers", type: .toggle(value: true)),
                Setting(name: "Offset page numbers by", type: .number(value: -3))
            ]
        case .pages:
            return [
                Setting(name: "Double paged", type: .toggle(value: true)),
                Setting(name: "Offset pages by 1 (use this to view double page spreads)", type: .toggle(value: false))
            ]
        }
    }
}
