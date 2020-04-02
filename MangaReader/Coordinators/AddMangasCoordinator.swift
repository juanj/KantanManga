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
    private var filePath: String?
    private var collection: MangaCollection?

    init(navigation: UINavigationController, delegate: AddMangasCoordinatorDelegate) {
        navigationController = navigation
        self.delegate = delegate
    }

    func start(button: UIBarButtonItem) {
        let addMangaView = AddMangaViewController(delegate: self)
        presentedNavigationController.pushViewController(addMangaView, animated: true)
        presentedNavigationController.modalPresentationStyle = .popover
        presentedNavigationController.popoverPresentationController?.barButtonItem = button
        presentedNavigationController.popoverPresentationController?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
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

    private func loadFile() {
        guard let filePath = self.filePath else { return }
        guard let addMangaViewController = self.addMangaViewController else { return }
        guard let reader = try? CBZReader(fileName: filePath) else {
            print("Error creating CBZReader")
            return
        }
        reader.readFirstEntry { (data) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                addMangaViewController.coverImageView.image = UIImage(data: data)
                addMangaViewController.selectFileButton.setTitle(filePath, for: .normal)
                addMangaViewController.selectFileButton.setTitleColor(.label, for: .normal)
                if addMangaViewController.nameTextField.text == nil || addMangaViewController.nameTextField.text!.isEmpty {
                    let name: String = {
                        var splited = filePath.split(separator: ".")
                        splited.removeLast()
                        return splited.joined()
                    }()
                    addMangaViewController.nameTextField.text = name
                }
            }
        }
        presentedNavigationController.popToRootViewController(animated: true)
    }
}

extension AddMangasCoordinator: GCDWebUploaderDelegate {
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        let soundID: SystemSoundID = 1307
        AudioServicesPlaySystemSound(soundID)
        filePath = path.lastPathComponent
        uploadServer?.stop()
        loadFile()
    }

    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        let fileName = path.lastPathComponent
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

    func save(addMangaViewController: AddMangaViewController, name: String?) {
        guard let name = name, !name.isEmpty else {
            return
        }
        guard let file = self.filePath else {
            return
        }
        CoreDataManager.sharedManager.createMangaWith(filePath: file, name: name, collection: collection) { (_) in
            DispatchQueue.main.sync {
                self.navigationController.dismiss(animated: true, completion: nil)
                self.delegate?.didEnd(self)
            }
        }
    }

    func selectManga(addMangaViewController: AddMangaViewController) {
        presentedNavigationController.pushViewController(FileSourceViewController(delegate: self), animated: true)
    }

    func selectCollection(addMangaViewController: AddMangaViewController) {
        presentedNavigationController.pushViewController(SelectCollectionTableViewController(delegate: self, collections: CoreDataManager.sharedManager.fetchAllCollections() ?? []), animated: true)
    }
}

extension AddMangasCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.cancel(self)
    }
}

extension AddMangasCoordinator: FileSourceViewControllerDelegate {
    func openWebServer(fileSourceViewController: FileSourceViewController) {
        initWebServer()
        let webServerViewcontroller = WebServerViewController()
        webServerViewcontroller.delegate = self
        if let url = uploadServer?.serverURL?.absoluteString {
            webServerViewcontroller.serverUrl = url
        }
        presentedNavigationController.pushViewController(webServerViewcontroller, animated: true)
    }

    func openLocalFiles(fileSourceViewController: FileSourceViewController) {
        let filesView = UIDocumentPickerViewController(documentTypes: ["public.zip-archive"], in: .import)
        filesView.allowsMultipleSelection = false
        filesView.title = "Local files"
        filesView.delegate = self
        presentedNavigationController.present(filesView, animated: true, completion: nil)
    }
}

extension AddMangasCoordinator: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first,
              let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = fileUrl.lastPathComponent
        var newFileUrl = documentsUrl.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: newFileUrl.path) {
            let timeStamp = Date().timeIntervalSince1970
            newFileUrl = documentsUrl.appendingPathComponent("\(Int(timeStamp))-\(fileName)")
        }

        do {
            try FileManager.default.moveItem(at: fileUrl, to: newFileUrl)
            filePath = fileName
            loadFile()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension AddMangasCoordinator: SelectCollecionTableViewControllerDelegate {
    func selectCollection(selectCollectionTableViewController: SelectCollectionTableViewController, collection: MangaCollection) {
        self.collection = collection
        addMangaViewController?.selectCollectionButton.setTitle(collection.name, for: .normal)
        addMangaViewController?.selectCollectionButton.setTitleColor(.label, for: .normal)
        presentedNavigationController.popViewController(animated: true)
    }

    func addCollection(selectCollectionTableViewController: SelectCollectionTableViewController, name: String) {
        guard let collection = CoreDataManager.sharedManager.insertCollection(name: name) else { return }
        self.collection = collection
        addMangaViewController?.selectCollectionButton.setTitle(collection.name, for: .normal)
        addMangaViewController?.selectCollectionButton.setTitleColor(.label, for: .normal)
        presentedNavigationController.popViewController(animated: true)
    }
}
