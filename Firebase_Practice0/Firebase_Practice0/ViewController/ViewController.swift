//
//  ViewController.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/10.
//

import UIKit
import Firebase

final class ViewController: UIViewController {

    @IBOutlet private weak var registerEmailTextField: UITextField!
    @IBOutlet private weak var registerPasswordTextField: UITextField!
    @IBOutlet private weak var registerNameTextField: UITextField!
    @IBOutlet private weak var loginEmailTextField: UITextField!
    @IBOutlet private weak var loginPasswordTextField: UITextField!

    @IBAction func tapRegisterButton(_ sender: Any) {
        if let email = registerEmailTextField.text,
           let password = registerPasswordTextField.text,
           let name = registerNameTextField.text {
            // nilじゃなかったらFirebaseAuthにemailとpasswordでアカウントを作成する
            // 成功したら、resultに作成されたユーザー情報が(正確には他の情報も)入り、エラーの場合はerrorという変数にerrorが入る
            Auth.auth().createUser(withEmail: email,
                                   password: password,
                                   completion: { (result, error) in
                                    // 作成されたユーザー情報はresult.userに入っている
                                    if let user = result?.user {
                                        print("ユーザー作成完了 uid:" + user.uid)
                                        // FirestoreのUsersコレクションにログインしたuserのuidドキュメントにデータを作成する
                                        // ここでコレクションとドキュメントを両方作成している
                                        Firestore.firestore().collection("users").document(user.uid).setData([
                                            "name": name
                                        ], completion: { error in
                                            if let error = error {
                                                FuncUtility.showErrorDialog(error: error,
                                                                            title: "Firestoreでの新規登録の失敗",
                                                                            currentVC: self)
                                            } else {
                                                print("Firestoreでの新規登録完了！")
                                                FuncUtility.presentNextViewController(currentVC: self,
                                                                                      withNextVCIdentifier: "TodoListViewController")
                                            }
                                        })
                                    } else if let error = error {
                                        FuncUtility.showErrorDialog(error: error,
                                                                    title: "Authでの新規登録の失敗",
                                                                    currentVC: self)
                                    }
                                   })
        }


    }

    @IBAction func tapLoginButton(_ sender: Any) {
        if let email = loginEmailTextField.text,
           let password = loginPasswordTextField.text {
            Auth.auth().signIn(withEmail: email,
                               password: password,
                               completion: { (result, error) in
                                if let user = result?.user {
                                    print("ログイン完了 uid:" + user.uid)
                                    FuncUtility.presentNextViewController(currentVC: self,
                                                                          withNextVCIdentifier: "TodoListViewController")
                                } else if let error = error {
                                    // authのユーザー情報の認証のerrorがnilじゃないとき = errorがあるとき
                                    FuncUtility.showErrorDialog(error: error,
                                                                title: "ログイン失敗",
                                                                currentVC: self)
                                }
                               })
        }
    }

}

