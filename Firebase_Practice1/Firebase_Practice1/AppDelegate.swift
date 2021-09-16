//
//  AppDelegate.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit
import Firebase
//import FirebaseAuth
//import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
//        IQKeyboardManager.shared.enable = true
        User.registerUserToAuth()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let folderVC = FolderViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: folderVC)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        return true
    }
}

