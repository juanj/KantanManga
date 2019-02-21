//
//  AddMangasCoordinator.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import ZIPFoundation

protocol AddMangasCoordinatorDelegate {
    func didEnd(_ addMangasCoordinator: AddMangasCoordinator)
}

class AddMangasCoordinator: NSObject{
    var navigationController: UINavigationController!
    var delegate: AddMangasCoordinatorDelegate?
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
        CoreDataManager.sharedManager.createMangaWith(filePath: path)
    }
}

extension AddMangasCoordinator: WebServerViewControllerDelegate {
    func didSelectBack(_ webServerViewController: WebServerViewController) {
        self.navigationController.popViewController(animated: true)
        self.uploadServer?.stop()
        self.delegate?.didEnd(self)
    }
}
