//
//  ViewerSettings.swift
//  Kantan-Manga
//
//  Created by Juan on 4/11/20.
//

import Foundation

protocol SettingRepresentable {
    var title: String { get }
    var value: SettingValue { get }
}

enum SettingValue {
    case bool(value: Bool)
    case number(value: Int)
}

struct SettingsSection {
    let title: String
    var settings: [SettingRepresentable]
}

enum ViewerPagesSettings: SettingRepresentable {
    case doublePaged(Bool)
    case offsetByOne(Bool)

    var title: String {
        switch self {
        case .doublePaged:
            return "Double paged"
        case .offsetByOne:
            return "Offset pages by 1 (use this to view double page spreads)"
        }
    }

    var value: SettingValue {
        switch self {
        case .doublePaged(let value):
            return .bool(value: value)
        case .offsetByOne(let value):
            return .bool(value: value)
        }
    }
}

enum ViewerPageNumberSettings: SettingRepresentable {
    case hidePageNumbers(Bool)
    case offsetPageNumbesr(Int)

    var title: String {
        switch self {
        case .hidePageNumbers:
            return "Hide page numbers"
        case .offsetPageNumbesr:
            return "Offset page numbers by"
        }
    }

    var value: SettingValue {
        switch self {
        case .hidePageNumbers(let value):
            return .bool(value: value)
        case .offsetPageNumbesr(let value):
            return .number(value: value)
        }
    }
}
