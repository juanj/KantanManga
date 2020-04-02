//
//  String+Extension.swift
//  MangaReader
//
//  Created by Juan on 2/04/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

extension String {
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
}
