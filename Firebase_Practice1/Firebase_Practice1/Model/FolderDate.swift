//
//  FolderDate.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import Foundation
import Firebase
import FirebaseAuth

// FolderDates(サブコレクション)
    // folderDate.id(ドキュメント)
        // year(フィールド)
        // month(フィールド)
        // createAt(フィールド)
        // （実際には次に FileDates(同じようなドキュメントとサブコレクションの関係性が続く)）

final class FolderDate: NSObject {
    var id: String
    var year: Int
    var month: Int
    var createAt: Date

    // folderDateは複数のドキュメントが作れれるものなのでQueryDocumentSnapshot
    init(doc: QueryDocumentSnapshot) {
        self.id = doc.documentID

        let data = doc.data()
        self.year = data["year"] as! Int
        self.month = data["month"] as! Int
        let createAtTimestamp = data["createAt"] as? Timestamp

        if let createAt = createAtTimestamp {
            self.createAt = createAt.dateValue() // Timestamp型からDate型に変換
        } else {
            self.createAt = Date()
        }
    }

    // 【実行】ここにFolderSectionを入れて、"\(folderSection.id)"みたいに入れてあげると良さそう？
    static func createFolderDateToFirestore(
                                            year: Int,
                                            month: Int) {
        if let user = Auth.auth().currentUser {
            let createTime = FieldValue.serverTimestamp()
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").document().setData([
                "year": year,
                "month": month,
                "createAt": createTime
            ],
            merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
            completion: { error in
                if let error = error {
                    print("FolderDateの作成失敗" + error.localizedDescription)
                } else {
                    print("FolderDateの作成成功")
                }
            })
        }
    }

    // 配列が欲しいので、yearが一致したものでmonthで並び替えたものを取ってくる？ → これやってみる
    static func showFolderDateForFirestore(
                                           completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            // whereField("year", イコールyear)は今の所なくても大丈夫そう？？？
            // "users/\(user.uid)/folderSections/folderDates/folderDate"
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").order(by: "month", descending: true).addSnapshotListener( {(querySnapshot, error) in
                completionAction(querySnapshot, error)
            })
        }
    }
}

