//
//  ToDo.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/12.
//

import Firebase

final class Todo: NSObject {
    var id: String
    var title: String
    var detail: String
    var isDone: Bool
    var createAt: Date
    var updateAt: Date

    init(doc: QueryDocumentSnapshot) {
        self.id = doc.documentID

        let data = doc.data()
        self.title = data["title"] as! String
        self.detail = data["detail"] as! String
        self.isDone = data["isDone"] as! Bool

        let createAtTimestamp = data["createAt"] as? Timestamp
        let updateAtTimestamp = data["updateAt"] as? Timestamp

        if let createAt = createAtTimestamp,
           let updateAt = updateAtTimestamp {
            self.createAt = createAt.dateValue() // Timestamp型からDate型に変換
            self.updateAt = updateAt.dateValue()
        } else {
            // もしnilだった場合
            self.createAt = Date()
            self.updateAt = Date()
        }
    }

    static func getTodoListDataForFirestore(isDone: Bool,
                                            completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createAt").addSnapshotListener( {(querySnapshot, error) in
                completionAction(querySnapshot, error)
            })
        }
    }

    static func createTodoToFirestore(title: String,
                                      detail: String,
                                      currentVC: UIViewController) {
        if let user = Auth.auth().currentUser {
            let createTime = FieldValue.serverTimestamp()
            // documentはないので空のままでいい
            Firestore.firestore().collection("users/\(user.uid)/todos").document().setData([
                "title": title,
                "detail": detail,
                "isDone": false,
                "createAt": createTime,
                "updateAt": createTime
            ],
            merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
            completion: { error in
                if let error = error {
                    FuncUtility.showErrorDialog(error: error,
                                                title: "Todoの作成失敗",
                                                currentVC: currentVC)
                } else {
                    print("Todoの作成成功")
                    currentVC.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    static func isDoneUpdate(todo: Todo,
                             complectionAction: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todo.id).updateData([
                "isDone": !todo.isDone,
                "updateAt": FieldValue.serverTimestamp()
            ], completion: { error in
                complectionAction(error)
            })
        }
    }

    static func updateContentIsDoneTapped(todo: Todo,
                                          currentVC: UIViewController) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todo.id).updateData([
                "title": todo.title,
                "detail": todo.detail,
                "isDone": !todo.isDone,
                "updateAt": FieldValue.serverTimestamp()
            ], completion: { error in
                if let error = error {
                    FuncUtility.showErrorDialog(error: error,
                                                title: "Todo更新失敗",
                                                currentVC: currentVC)
                } else {
                    print("Todo更新成功")
                    currentVC.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    static func updateContentEditTapped(todo: Todo,
                                        currentVC: UIViewController) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todo.id).updateData([
                "title": todo.title,
                "detail": todo.detail,
                "updateAt": FieldValue.serverTimestamp()
            ], completion: { error in
                if let error = error {
                    FuncUtility.showErrorDialog(error: error,
                                                title: "Todo更新失敗",
                                                currentVC: currentVC)
                } else {
                    print("Todo更新成功")
                    currentVC.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    // ２パターンあるのでクロージャを用意
    static func delete(todo: Todo,
                       complectionAction: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todo.id).delete(completion: { error in
                complectionAction(error)
            })
        }
    }
}
