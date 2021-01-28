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

class AddMangasCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    private var navigation: Navigable
    private lazy var presentedNavigationController = createPresentableNavigation()
    private var sourceButton: UIBarButtonItem
    private var uploadServer: GCDWebUploader
    private let coreDataManager: CoreDataManageable
    private weak var delegate: AddMangasCoordinatorDelegate?

    private var addMangaViewController: AddMangaViewController?
    private var filePath: String?
    private var collection: MangaCollection?

    init(navigation: Navigable, sourceButton: UIBarButtonItem, uploadServer: GCDWebUploader, coreDataManager: CoreDataManageable, delegate: AddMangasCoordinatorDelegate) {
        self.navigation = navigation
        self.sourceButton = sourceButton
        self.uploadServer = uploadServer
        self.coreDataManager = coreDataManager
        self.delegate = delegate
    }

    func start() {
        let addMangaView = AddMangaViewController(delegate: self)
        presentedNavigationController.setViewControllers([addMangaView], animated: false)
        navigation.present(presentedNavigationController, animated: true, completion: nil)

        addMangaViewController = addMangaView
    }

    func createPresentableNavigation() -> Navigable {
        let presentableNavigation = UINavigationController()
        presentableNavigation.modalPresentationStyle = .popover
        presentableNavigation.popoverPresentationController?.barButtonItem = self.sourceButton
        presentableNavigation.popoverPresentationController?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        presentableNavigation.presentationController?.delegate = self
        return presentableNavigation
    }

    private func initWebServer() {
        uploadServer.allowedFileExtensions = ["cbz", "zip", "rar", "cbr"]
        uploadServer.delegate = self
        uploadServer.start()
    }

    private func loadFile() {
        guard let filePath = self.filePath else { return }
        guard let addMangaViewController = self.addMangaViewController else { return }
        let reader: Reader
        do {
            if filePath.lowercased().hasSuffix("cbz") || filePath.lowercased().hasSuffix("zip") {
                reader = try CBZReader(fileName: filePath)
            } else {
                reader = try CBRReader(fileName: filePath)
            }
        } catch {
            print("Error creating reader")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Wait one second after upload so the page has time to refresh and don't show an error
            let soundID: SystemSoundID = 1307
            AudioServicesPlaySystemSound(soundID)
            self.filePath = path.lastPathComponent
            self.uploadServer.stop()
            self.loadFile()
        }
    }

    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        let fileName = path.lastPathComponent
        if let manga = coreDataManager.getMangaWith(filePath: fileName) {
            coreDataManager.delete(manga: manga)
        }
    }
}

extension AddMangasCoordinator: WebServerViewControllerDelegate {
    func didSelectBack(_ webServerViewController: WebServerViewController) {
        presentedNavigationController.popViewController(animated: true)
        uploadServer.stop()
    }
}

extension AddMangasCoordinator: AddMangaViewControllerDelegate {
    func cancel(_ addMangaViewController: AddMangaViewController) {
        navigation.dismiss(animated: true, completion: nil)
        delegate?.cancel(self)
    }

    func save(_ addMangaViewController: AddMangaViewController, name: String?) {
        guard let name = name, !name.isEmpty else {
            return
        }
        guard let file = self.filePath else {
            return
        }
        coreDataManager.createMangaWith(filePath: file, name: name, collection: collection) { (_) in
            DispatchQueue.main.sync {
                self.navigation.dismiss(animated: true, completion: nil)
                self.delegate?.didEnd(self)
            }
        }
    }

    func selectManga(_ addMangaViewController: AddMangaViewController) {
        presentedNavigationController.pushViewController(FileSourceViewController(delegate: self), animated: true)
    }

    func selectCollection(_ addMangaViewController: AddMangaViewController) {
        presentedNavigationController.pushViewController(SelectCollectionTableViewController(delegate: self, collections: coreDataManager.fetchAllCollections() ?? []), animated: true)
    }
}

extension AddMangasCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.cancel(self)
    }
}

extension AddMangasCoordinator: FileSourceViewControllerDelegate {
    func openWebServer(_ fileSourceViewController: FileSourceViewController) {
        initWebServer()
        let webServerViewcontroller = WebServerViewController()
        webServerViewcontroller.delegate = self
        if let url = uploadServer.serverURL?.absoluteString {
            webServerViewcontroller.serverUrl = url
        }
        presentedNavigationController.pushViewController(webServerViewcontroller, animated: true)
    }

    func openLocalFiles(_ fileSourceViewController: FileSourceViewController) {
        let filesView = UIDocumentPickerViewController(documentTypes: ["public.zip-archive", "com.rarlab.rar-archive"], in: .import)
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

extension AddMangasCoordinator: SelectCollectionTableViewControllerDelegate {
    func selectCollection(_ selectCollectionTableViewController: SelectCollectionTableViewController, collection: MangaCollection) {
        self.collection = collection
        addMangaViewController?.selectCollectionButton.setTitle(collection.name, for: .normal)
        addMangaViewController?.selectCollectionButton.setTitleColor(.label, for: .normal)
        presentedNavigationController.popViewController(animated: true)
    }

    func addCollection(_ selectCollectionTableViewController: SelectCollectionTableViewController, name: String) {
        guard let collection = coreDataManager.insertCollection(name: name) else { return }
        self.collection = collection
        addMangaViewController?.selectCollectionButton.setTitle(collection.name, for: .normal)
        addMangaViewController?.selectCollectionButton.setTitleColor(.label, for: .normal)
        presentedNavigationController.popViewController(animated: true)
    }
}
