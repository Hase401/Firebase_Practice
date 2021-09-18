//
//  FolderSection.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import Foundation
import Firebase
import FirebaseAuth

// FolderSections(サブコレクション)
    // folderSection.id (ドキュメント)
        // year(フィールド)
        // totalDayInYearSection(フィールド)
        // isShowed(フィールド)
        // createAt(フィールド)
        // updateAt(フィールド)
        // FolderDates(サブコレクション) → 次のファイルへ

final class FolderSection: NSObject {
    var id: String
    var year: Int
    var totalDayInYearSection: Int
    var isShowed: Bool
    var createAt: Date
    var updateAt: Date

    // QueryDocumentSnapshotはQuerySnapshotに入っている1つ1つのドキュメント
    init(doc: QueryDocumentSnapshot) {
        self.id = doc.documentID

        let data = doc.data() // !が付くQueryDocumentSnapshotにするとDocumentSnapshotになる
        self.year = data["year"] as? Int ?? 0
        self.totalDayInYearSection = data["totalDayInYearSection"] as? Int ?? 0
        self.isShowed = data["isShowed"] as? Bool ?? true
        let createAtTimestamp = data["createcAt"] as? Timestamp
        let updateAtTimestamp = data["updateAt"] as? Timestamp
        if let createAt = createAtTimestamp,
           let updateAt = updateAtTimestamp {
            self.createAt = createAt.dateValue() // Timestamp型からDate型に変換
            self.updateAt = updateAt.dateValue()
        } else {
            self.createAt = Date()
            self.updateAt = Date()
        }
    }

    static func createFolderSectionToFirestore(year: Int,
                                               completionAction: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            let createTime = FieldValue.serverTimestamp()
            // 【曖昧】コレクションはこれで定義して理想通りになっているか失敗しててもいいから実際にコンソールで検証するべきだな。。。
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").document().setData([
                "year": year,
                "totalDayInYearSection": 0,
                "isShowed": true,
                "createAt": createTime,
                "updateAt": createTime
            ],
            merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
            completion: { error in
                completionAction(error)
            })
        }
    }

    // 配列が欲しいので、yearで並び替えたものを取ってくる
    // クエリが1つだけなので普通のSnapshotでgetDocumentメソッドで良さそう？
    static func showFolderSectionsForFirestore(completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").order(by: "year", descending: true).addSnapshotListener({(QuerySnapshot, error) in
                completionAction(QuerySnapshot, error)
            })
        }
    }

    static func isShowedUpdate(folderSection: FolderSection,
                             completionAction: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").document(folderSection.id).updateData([
                "isShowed": !folderSection.isShowed,
                "updateAt": FieldValue.serverTimestamp()
            ], completion: { error in
                completionAction(error)
            })
        }
    }

    // これはupdateとして必要
    static func calculateTotalDayInYearSection(folderSection: FolderSection,
                                               folderDates: [FolderDate], // これのtotalDayInMonthをfor文で回して計算すればいいかも！
//                                               totalDay: Int,
                                               completionAction: @escaping (Error?) -> Void) {
        print("folderDates:", folderDates)
        print("folderDates.count:", folderDates.count)
        if folderDates.count == 0 {
            return // もともとtotalDayInYearSectionは0だから
        }
        if let user = Auth.auth().currentUser {
            var totalDay: Int = 0
            for i in 0...folderDates.count-1 {
                totalDay += folderDates[i].totalDayInMonth
            }
            print("totalDay:", totalDay)

            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").document(folderSection.id).updateData([
                "totalDayInYearSection": totalDay,
                "updateAt": FieldValue.serverTimestamp()
            ], completion: { error in
                completionAction(error)
            })
        }
    }
}
