//
//  MockUploadServer.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import MangaReader

class MockUploadServer: GCDWebUploader {
    var startCalled = false
    var stopCalled = false
    override func start() -> Bool {
        startCalled = true
        return true
    }
    override func stop() {
        stopCalled = true
    }
}
