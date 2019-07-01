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
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white

        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController
        self.appCoordinator = AppCoordinator(navigation: navigationController)
        self.appCoordinator.start()
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.sharedManager.saveContext()
    }

}
