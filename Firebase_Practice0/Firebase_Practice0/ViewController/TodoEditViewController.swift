//
//  TodoEditViewController.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/10.
//

import UIKit
import Firebase

final class TodoEditViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var isDoneLabel: UILabel!

    // 一覧画面から受け取るように変数を用意
    var todoId: String!
    var todoTitle: String!
    var todoDetail: String!
    var todoIsDone: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 初期値としてセット
        titleTextField.text = todoTitle
        detailTextView.text = todoDetail

        switch todoIsDone {
        case false:
            isDoneLabel.text = "未完了"
            doneButton.setTitle("完了済みにする", for: .normal)
        default: // デフォルトはtrue?
            isDoneLabel.text = "完了"
            doneButton.setTitle("未完了にする", for: .normal)
        }
    }

    override func viewDidLayoutSubviews() {
         detailTextView.layer.borderWidth = 1.0
         detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
         detailTextView.layer.cornerRadius = 5.0
         detailTextView.layer.masksToBounds = true
     }

     @IBAction func tapEditButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData([
                    "title": title,
                    "detail": detail,
                    "updateAt": FieldValue.serverTimestamp()
                ], completion: { error in
                    if let error = error {
                        FuncUtility.showErrorDialog(error: error,
                                                    title: "ToDo更新失敗",
                                                    currentVC: self)
                    } else {
                        print("TODO更新成功")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
     }

    // 本来はここでも最新のtextFieldの値を取ってきて変えた方がユーザー体験からするといい
    @IBAction func tapDoneButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            // 完了、未完了切り替えボタンの実装
            if let user = Auth.auth().currentUser {
                // データの更新を行う場合はdocument("更新するドキュメントのID")が必要なので
                // 遷移時にdocumentIDとしてtodoIDを渡している
                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData([
                    "isDone": !todoIsDone, // toggleさせる？
                    "title": title,
                    "detail": detail,
                    "updateAt": FieldValue.serverTimestamp()
                ], completion: { error in
                    if let error = error {
                        FuncUtility.showErrorDialog(error: error,
                                                    title: "ToDo更新失敗",
                                                    currentVC: self)
                    } else {
                        print("TODO更新成功")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
     }

     @IBAction func tapDeleteButton(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).delete() { error in
                if let error = error {
                    FuncUtility.showErrorDialog(error: error,
                                                title: "ToDo削除失敗",
                                                currentVC: self)
                } else {
                    print("TODO削除成功")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
     }

}
