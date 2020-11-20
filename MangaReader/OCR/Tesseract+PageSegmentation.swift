//
//  Tesseract+PageSegmentation.swift
//  Kantan-Manga
//
//  Created by Juan on 20/11/20.
//

import SwiftyTesseract
import libtesseract

public typealias PageSegmentationMode = TessPageSegMode
public extension PageSegmentationMode {
    static let osdOnly = PSM_OSD_ONLY
    static let autoOsd = PSM_AUTO_OSD
    static let autoOnly = PSM_AUTO_ONLY
    static let auto = PSM_AUTO
    static let singleColumn = PSM_SINGLE_COLUMN
    static let singleBlockVerticalText = PSM_SINGLE_BLOCK_VERT_TEXT
    static let singleBlock = PSM_SINGLE_BLOCK
    static let singleLine = PSM_SINGLE_LINE
    static let singleWord = PSM_SINGLE_WORD
    static let circleWord = PSM_CIRCLE_WORD
    static let singleCharacter = PSM_SINGLE_CHAR
    static let sparseText = PSM_SPARSE_TEXT
    static let sparseTextOsd = PSM_SPARSE_TEXT_OSD
    static let count = PSM_COUNT
}

public extension Tesseract {
    var pageSegmentationMode: PageSegmentationMode {
        get {
            perform { tessPointer in
                TessBaseAPIGetPageSegMode(tessPointer)
            }
        }
        set {
            perform { tessPointer in
                TessBaseAPISetPageSegMode(tessPointer, newValue)
            }
        }
    }
}
