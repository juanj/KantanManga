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
    func cancel(_ addMangasCoordinator: AddMangasCoordinator)
}

class AddMangasCoordinator: NSObject {
    private var navigationController: UINavigationController!
    private var presentedNavigationController = UINavigationController()
    private weak var delegate: AddMangasCoordinatorDelegate?

    private var uploadServer: GCDWebUploader?
    private var addMangaViewController: AddMangaViewController?

    init(navigation: UINavigationController, delegate: AddMangasCoordinatorDelegate) {
        navigationController = navigation
        self.delegate = delegate
    }

    func start() {
        let addMangaView = AddMangaViewController(delegate: self)
        presentedNavigationController.pushViewController(addMangaView, animated: true)
        presentedNavigationController.modalPresentationStyle = .formSheet
        presentedNavigationController.presentationController?.delegate = self
        navigationController.present(presentedNavigationController, animated: true, completion: nil)

        addMangaViewController = addMangaView
    }

    private func initWebServer() {
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
        addMangaViewController?.setFile(path: path)
        presentedNavigationController.popViewController(animated: true)
        uploadServer?.stop()
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
        presentedNavigationController.popViewController(animated: true)
        uploadServer?.stop()
    }
}

extension AddMangasCoordinator: AddMangaViewControllerDelegate {
    func cancel(addMangaViewController: AddMangaViewController) {
        navigationController.dismiss(animated: true, completion: nil)
        delegate?.cancel(self)
    }

    func save(addMangaViewController: AddMangaViewController, name: String, path: String, collection: MangaCollection?) {
        CoreDataManager.sharedManager.createMangaWith(filePath: path, name: name) { (_) in
            DispatchQueue.main.sync {
                self.navigationController.dismiss(animated: true, completion: nil)
                self.delegate?.didEnd(self)
            }
        }
    }

    func selectManga(addMangaViewController: AddMangaViewController) {
        initWebServer()
        let webServerViewcontroller = WebServerViewController()
        webServerViewcontroller.delegate = self
        if let url = uploadServer?.serverURL?.absoluteString {
            webServerViewcontroller.serverUrl = url
        }
        presentedNavigationController.pushViewController(webServerViewcontroller, animated: true)
    }
}

extension AddMangasCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.cancel(self)
    }
}
