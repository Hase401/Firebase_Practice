//
//  User.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/11.
//

import Firebase

// User(コレクション)/id(ドキュメント)/name(フィールド)
final class User: NSObject {
    var id: String
    var name: String

    // name1つだけなのでDocumentSnapshot
    init(doc: DocumentSnapshot) {
        self.id = doc.documentID
        let data = doc.data()
        // フィールドとしてのKey-Value
        // [String: Any]?型なのでアンラップしてあげる
        self.name = data!["name"] as! String
    }

    // ここにViewControllerとかtitleとか持ってきてFucnUtilityまで中で実行してあげるといいかもね
    static func registerUserToAuth(email: String,
                                   password: String,
                                   userName: String,
                                   errorTitle: String,
                                   currentVC: UIViewController) {
        // 実際の引数から受け取って実行する中身
        // プロパティに渡さずそのまま関数の中で引数として持っているのでそれで実行
        Auth.auth().createUser(withEmail: email,
                               password: password,
                               completion: { (result, error) in
                                if let user = result?.user {
                                    print("新規ユーザー作成完了！ uid: " + user.uid) // user.uidが自動で作られる
                                    User.createUserToFirestore(userId: user.uid,
                                                               userName: userName,
                                                               errorTitle: "UserNameのデータを作成の失敗",
                                                               currentVC: currentVC)
                                } else if let error = error {
                                    FuncUtility.showErrorDialog(error: error,
                                                                title: errorTitle,
                                                                currentVC: currentVC)
                                }
                               })
    }

    static func createUserToFirestore(userId: String,
                                      userName: String,
                                      errorTitle: String,
                                      currentVC: UIViewController) {
        Firestore.firestore().collection("users").document(userId).setData([
            "name": userName
        ], completion: { error in
            if let error = error {
                FuncUtility.showErrorDialog(error: error,
                                            title: errorTitle,
                                            currentVC: currentVC)
            } else {
                print("UserNameのデータを作成完了！")
                FuncUtility.presentNextViewController(currentVC: currentVC,
                                                      withNextVCIdentifier: "TodoListViewController")
            }
        })
    }

    static func loginUserToAuth(email: String,
                                password: String,
                                errorTitle: String,
                                currentVC: UIViewController) {
        Auth.auth().signIn(withEmail: email,
                           password: password,
                           completion: { (result, error) in
                            if let user = result?.user {
                                print("ログイン完了！ uid: " + user.uid)
                                FuncUtility.presentNextViewController(currentVC: currentVC,
                                                                      withNextVCIdentifier: "TodoListViewController")
                            } else if let error = error {
                                FuncUtility.showErrorDialog(error: error,
                                                            title: errorTitle,
                                                            currentVC: currentVC)
                            }
                           })
    }

    // labelに名前を表示してあげる必要があるので引数にクロージャを使うしかない
    static func getUserDataForFireStore(completionAction: @escaping (DocumentSnapshot?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users").document(user.uid).getDocument(completion: { (snapshot, error) in
                completionAction(snapshot, error)
            })
        }
    }

}
