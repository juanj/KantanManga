//
//  AppDelegate.swift
//  MangaReader
//
//  Created by admin on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController
        let appCoordinator = AppCoordinator(navigation: navigationController)
        appCoordinator.start()
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.sharedManager.saveContext()
    }

}

