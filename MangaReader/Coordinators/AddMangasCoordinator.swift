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
        navigationController = navigation
    }

    func start() {
        initWebServer()
        let webServerViewcontroller = WebServerViewController()
        webServerViewcontroller.delegate = self
        if let url = uploadServer?.serverURL?.absoluteString {
            webServerViewcontroller.serverUrl = url
        }
        navigationController.pushViewController(webServerViewcontroller, animated: true)
    }

    func initWebServer() {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        uploadServer = GCDWebUploader(uploadDirectory: documentPath)
        uploadServer?.allowedFileExtensions = ["cbz", "zip"]
        uploadServer?.delegate = self
        uploadServer?.start()
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
        navigationController.popViewController(animated: true)
        uploadServer?.stop()
        delegate?.didEnd(self)
    }
}
