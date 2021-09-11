//
//  TodoAddViewController.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/10.
//

import UIKit
import Firebase

final class TodoAddViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!

    override func viewDidLayoutSubviews() {
        // TextViewのレイアウトをTextFieldに合わせるためのコード
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        detailTextView.layer.cornerRadius = 5.0
        detailTextView.layer.masksToBounds = true
    }

    @IBAction func tapAddButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            // ログイン済みか確認
            if let user = Auth.auth().currentUser {
                // FirestoreにTodoデータを作成する
                // 時刻系の作成はFieldValue.serverTimestamp()を使用することが多い // サーバー側
                let createdTime = FieldValue.serverTimestamp() // FieldValue型とは？？
                // データベースの設計でusers/userId/todosにデータの作成を行う // これがサブコレクションか
                Firestore.firestore().collection("users/\(user.uid)/todos").document().setData([
                    // 作成するデータ
                    "title": title,
                    "detail": detail,
                    "isDone": false, // 初期値は未完了とするためfalse
                    "createAt": createdTime,
                    "updateAt": createdTime
                ],
                // falseの場合はどんな時も新規データとして作成する // usersにあるnameの値などは消えてしまう？
                // trueの場合データがある時はupdateを行い、データがない場合はcreateを行う
                merge: true, // 階層にデータを作成する場合はこちらをtrueにする
                completion: { error in
                    if let error = error {
                        // FirestoreにTodoデータの作成に失敗してエラーがある場合
                        FuncUtility.showErrorDialog(error: error,
                                                    title: "ToDo作成失敗",
                                                    currentVC: self)
                    } else {
                        print("TODO作成成功")
                        // Todo一覧画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
