//
//  AppDelegate.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Auth.auth().signInAnonymously { authResult, error in
            if let user = authResult?.user {
                print("匿名ユーザーの新規作成成功！" + user.uid)
            } else if let error = error {
                print("匿名ユーザーの新規作成失敗。" + error.localizedDescription)
            }
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let folderVC = FolderViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: folderVC)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        return true
    }
}

