//
//  CGPDFObjectRef+Extension.swift
//  Kantan-Manga
//
//  Created by Juan on 8/02/21.
//

import Foundation

extension CGPDFObjectRef {
    func getName<K>(_ key: K, _ getter: (OpaquePointer, K, UnsafeMutablePointer<UnsafePointer<Int8>?>) -> Bool) -> String? {
        guard let pointer = self[getter, key] else { return nil }
        return String(cString: pointer)
    }

    func getName<K>(_ key: K, _ getter: (OpaquePointer, K, UnsafeMutableRawPointer?) -> Bool) -> String? {
        guard let pointer: UnsafePointer<UInt8> = self[getter, key] else { return nil }
        return String(cString: pointer)
    }

    subscript<R, K>(_ getter: (OpaquePointer, K, UnsafeMutablePointer<R?>) -> Bool, _ key: K) -> R? {
        var result: R!
        guard getter(self, key, &result) else { return nil }
        return result
    }

    subscript<R, K>(_ getter: (OpaquePointer, K, UnsafeMutableRawPointer?) -> Bool, _ key: K) -> R? {
        var result: R!
        guard getter(self, key, &result) else { return nil }
        return result
    }

    func getNameArray(for key: String) -> [String]? {
        var object: CGPDFObjectRef!
        guard CGPDFDictionaryGetObject(self, key, &object) else { return nil }

        if let name = object.getName(.name, CGPDFObjectGetValue) {
            return [name]
        } else {
            guard let array: CGPDFArrayRef = object[CGPDFObjectGetValue, .array] else {return nil}
            var names = [String]()
            for index in 0..<CGPDFArrayGetCount(array) {
                guard let name = array.getName(index, CGPDFArrayGetName) else { continue }
                names.append(name)
            }
            return names
        }
    }
}
