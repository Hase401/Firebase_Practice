//
//  FuncUtility.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/14.
//

import UIKit

final class FuncUtility {

    static func showErrorDialog(error: Error,
                                title: String,
                                currentVC: UIViewController) {
        print(title + error.localizedDescription)
        let dialog = UIAlertController(title: title,
                                       message: error.localizedDescription,
                                       preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default))
        currentVC.present(dialog, animated: true, completion: nil)
    }

//    static func presentNextViewController(currentVC: UIViewController,
//                                          withNextVCIdentifier: String) {
//        let storyboard: UIStoryboard = currentVC.storyboard!
//        let nextVC = storyboard.instantiateViewController(withIdentifier: withNextVCIdentifier)
//        currentVC.present(nextVC, animated: true, completion: nil)
//    }
}
