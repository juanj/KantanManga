//
//  Tokenizer.swift
//  mecab-ios-sample
//
//  Created by Landon Epps on 2018/04/13.
//  Copyright © 2018 Landon Epps. All rights reserved.
//

import Foundation
import mecab

/**
 A Swift wrapper for MeCab.
 
 Provides a simple function, parse(), to break a String into tokens.
*/
class Tokenizer {
    /// the original Objective-C MeCab wrapper
    var mecab: OpaquePointer?

    deinit {
        if mecab != nil {
            mecab_destroy(mecab)
        }
    }

    /**
     Parses a string with MeCab, and returns an array of Tokens.
     
     - parameter text: The String to be parsed.
     - returns: An array of Tokens. Each token represents a MeCab node.
    */
    func parse(_ text: String) -> [Token] {
        if mecab == nil {
            guard let path = Bundle.main.resourcePath else {
                fatalError("Could not get resource path")
            }
            mecab = mecab_new2("-d \(path)")
            if mecab == nil {
                fputs("error in mecab_new2: \(String(cString: mecab_strerror(nil)))\n", stderr)
                return []
            }
        }

        var nodePtr: UnsafePointer<mecab_node_t>?
        let buf = text.cString(using: .utf8)
        let len = text.lengthOfBytes(using: .utf8)
        nodePtr = mecab_sparse_tonode2(mecab, buf, len)

        if nodePtr == nil {
            fputs("error\n", stderr)
            return []
        }

        var tokens = [Token]()
        nodePtr = UnsafePointer(nodePtr?.pointee.next)

        // while the current node, and the next node are not nil
        // the last mecab node is just an empty node
        while nodePtr?.pointee.next != nil {
            guard let node = nodePtr?.pointee else {
                fatalError("Node is not nil, but we're unable to dereference it.")
            }

            if let newNode = Token(with: node) {
                tokens.append(newNode)
            }

            nodePtr = UnsafePointer(nodePtr?.pointee.next)
        }

        return tokens
    }
}
