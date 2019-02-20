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
    
    func createMangaWith(name: String, filePath path: String) {
        do {
            let reader = try CBZReader(filePath: path)
            reader.readFirstEntry { (data) in
                if let data = data {
                    let _ = CoreDataManager.sharedManager.insertManga(title: name, totalPages: Int16(reader.fileEntries.count), filePath: path, currentPage: 0, coverImage: data)
                }
            }
        } catch {
            print("Error creating CBZReader")
        }
    }
}

extension AddMangasCoordinator: GCDWebUploaderDelegate {
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        let alert = UIAlertController(title: "Uploaded", message: "A new file was uploaded.\nDo you want to create a manga entry for it now?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Manga name"
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let text = alert.textFields?[0].text, text != "" {
                self.createMangaWith(name: text, filePath: path)
            }
        }))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}

extension AddMangasCoordinator: WebServerViewControllerDelegate {
    func didSelectBack(_ webServerViewController: WebServerViewController) {
        self.navigationController.popViewController(animated: true)
        self.uploadServer?.stop()
        self.delegate?.didEnd(self)
    }
}
