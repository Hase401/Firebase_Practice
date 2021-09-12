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
            User.registerUserToAuth(email: email,
                                    password: password,
                                    userName: name,
                                    errorTitle: "Authでの新規登録失敗",
                                    currentVC: self)
        }
    }

    @IBAction func tapLoginButton(_ sender: Any) {
        if let email = loginEmailTextField.text,
           let password = loginPasswordTextField.text {
            User.loginUserToAuth(email: email,
                                 password: password,
                                 errorTitle: "ログイン失敗",
                                 currentVC: self)
        }
    }

}

