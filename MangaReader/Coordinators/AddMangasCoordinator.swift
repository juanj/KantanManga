//
//  AddMangasCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import AVFoundation
import ZIPFoundation

protocol AddMangasCoordinatorDelegate: AnyObject {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator)
}

class AddMangasCoordinator: NSObject {
    var navigationController: UINavigationController!
    weak var delegate: AddMangasCoordinatorDelegate?
    var uploadServer: GCDWebUploader?

    init(navigation: UINavigationController) {
        self.navigationController = navigation
    }

    func start() {
        self.initWebServer()
        let webServerViewcontroller = WebServerViewController()
        webServerViewcontroller.delegate = self
        if let url = self.uploadServer?.serverURL?.absoluteString {
            webServerViewcontroller.serverUrl = url
        }
        self.navigationController.pushViewController(webServerViewcontroller, animated: true)
    }

    func initWebServer() {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        self.uploadServer = GCDWebUploader(uploadDirectory: documentPath)
        self.uploadServer?.allowedFileExtensions = ["cbz", "zip"]
        self.uploadServer?.delegate = self
        self.uploadServer?.start()
    }
}

extension AddMangasCoordinator: GCDWebUploaderDelegate {
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        let soundID: SystemSoundID = 1307
        AudioServicesPlaySystemSound(soundID)
        CoreDataManager.sharedManager.createMangaWith(filePath: path)
    }

    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        let fileName = (path as NSString).lastPathComponent
        if let manga = CoreDataManager.sharedManager.getMangaWith(filePath: fileName) {
            CoreDataManager.sharedManager.delete(manga: manga)
        }
    }
}

extension AddMangasCoordinator: WebServerViewControllerDelegate {
    func didSelectBack(_ webServerViewController: WebServerViewController) {
        self.navigationController.popViewController(animated: true)
        self.uploadServer?.stop()
        self.delegate?.didEnd(self)
    }
}
