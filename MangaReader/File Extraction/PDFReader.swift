//
//  PDFReader.swift
//  Kantan-Manga
//
//  Created by Juan on 8/02/21.
//

import Foundation
import PDFKit

enum PDFReaderError: Error {
    case errorCreatingDocument
}

class PDFReader: Reader {
    private struct ImageInfo: CustomDebugStringConvertible {
        let name: String
        let colorSpaces: [String]
        let filter: [String]
        let format: CGPDFDataFormat
        let data: Data

        var debugDescription: String {
            """
              Image "\(name)"
               - color spaces: \(colorSpaces)
               - format: \(format == .JPEG2000 ? "JPEG2000" : format == .jpegEncoded ? "jpeg" : "raw")
               - filters: \(filter)
               - size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary))
            """
        }
    }

    var numberOfPages: Int {
        document.pageCount
    }

    private let document: PDFDocument

    required init(fileName: String) throws {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent(fileName)

        guard let document = PDFDocument(url: filePath) else {
            throw PDFReaderError.errorCreatingDocument
        }

        self.document = document
    }

    func readEntityAt(index: Int, _ completion: Completion?) {
        guard let page = document.page(at: index) else {
            completion?(nil)
            return
        }

        let extracted = extractImages(from: page) { image in
            completion?(image.data)
        }

        if !extracted {
            // Image extration failed. Fall back to rendering the page as an image
            completion?(renderPDF(page: page))
        }
    }

    // Working with pdf files is hard.
    // https://stackoverflow.com/a/57498699/2584078
    private func extractImages(from page: PDFPage, extractor: @escaping (ImageInfo) -> Void) -> Bool {
        guard let page = page.pageRef,
              let dictionary = page.dictionary,
              let resources = dictionary[CGPDFDictionaryGetDictionary, "Resources"] else {
            return false
        }

        var foundImage = false
        if let xObject = resources[CGPDFDictionaryGetDictionary, "XObject"] {
            func extractImage(key: UnsafePointer<Int8>, object: CGPDFObjectRef, info: UnsafeMutableRawPointer?) -> Bool {
                guard let stream: CGPDFStreamRef = object[CGPDFObjectGetValue, .stream] else { return true }
                guard let dictionary = CGPDFStreamGetDictionary(stream) else {return true}

                guard dictionary.getName("Subtype", CGPDFDictionaryGetName) == "Image" else {return true}

                let colorSpaces = dictionary.getNameArray(for: "ColorSpace") ?? []
                let filter = dictionary.getNameArray(for: "Filter") ?? []

                var format = CGPDFDataFormat.raw
                guard let data = CGPDFStreamCopyData(stream, &format) as Data? else { return false }

                extractor(
                  ImageInfo(
                    name: String(cString: key),
                    colorSpaces: colorSpaces,
                    filter: filter,
                    format: format,
                    data: data
                  )
                )
                foundImage = true

                // Stop iteration. Only want the first image
                return false
            }

            CGPDFDictionaryApplyBlock(xObject, extractImage, nil)
        }
        return foundImage
    }

    private func renderPDF(page: PDFPage) -> Data? {
        guard let page = page.pageRef else { return nil }

        // Double page size to try to preserve quality
        let pageRect = page.getBoxRect(.mediaBox).applying(CGAffineTransform(scaleX: 2, y: 2))

        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            // Flip UIKit coordinates
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.scaleBy(x: 2, y: 2)

            ctx.cgContext.drawPDFPage(page)
        }

        return img.jpegData(compressionQuality: 1)
    }
}
