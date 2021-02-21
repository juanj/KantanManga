//
//  AppDelegate.swift
//  MangaReader
//
//  Created by admin on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var libraryCoordinator: LibraryCoordinator!
    var coreDataManager: CoreDataManageable?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground

        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        let coreDataManager = CoreDataManager()
        libraryCoordinator = LibraryCoordinator(navigation: navigationController, coreDataManager: coreDataManager)
        libraryCoordinator.start()
        window?.makeKeyAndVisible()

        self.coreDataManager = coreDataManager
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataManager?.saveContext()
    }

}
