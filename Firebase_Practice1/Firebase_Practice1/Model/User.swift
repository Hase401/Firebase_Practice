//
//  Use.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/15.
//

import Firebase
import FirebaseAuth

// Users(コレクション)
    // user.uid(ドキュメント)
        // FolderSections(サブコレクション) → 次のファイルへ

final class User: NSObject {
    var id: String

    // classではイニシャライザが必要なので一応書く
    init(doc: DocumentSnapshot) {
        self.id = doc.documentID
    }

    // 【曖昧】これをどこで呼ぶのかわからないけど、公式ドキュメントはappDelegateって言っていた
    static func registerUserToAuth() {
        Auth.auth().signInAnonymously { authResult, error in
            if let user = authResult?.user {
                print("匿名ユーザーの新規作成成功！" + user.uid)
            } else if let error = error {
                print("匿名ユーザーの新規作成失敗。" + error.localizedDescription)
            }
        }
    }
}
