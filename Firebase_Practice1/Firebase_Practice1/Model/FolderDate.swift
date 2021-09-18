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
    var totalDayInMonth: Int // 追加してみた
    var createAt: Date
    var updateAt: Date // 追加してみた
//    var fileDates: [FileDate] // これはボツ

    // folderDateは複数のドキュメントが作れれるものなのでQueryDocumentSnapshot
    init(doc: QueryDocumentSnapshot) {
        self.id = doc.documentID

        let data = doc.data()
        self.year = data["year"] as? Int ?? 0
        self.month = data["month"] as? Int ?? 0
        self.totalDayInMonth = data["totalDayInMonth"] as? Int ?? 0
        let createAtTimestamp = data["createAt"] as? Timestamp
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

    // 【実行】ここにFolderSectionを入れて、"\(folderSection.id)"みたいに入れてあげると良さそうだけど
        // 辞書で管理しているので上手く渡しづらい。これはしゃーない。
        // 非同期処理のためにcompletionActionは結構必要
    static func createFolderDateToFirestore(year: Int,
                                            month: Int,
                                            completionAction: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            let createTime = FieldValue.serverTimestamp()
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").document().setData([
                "year": year,
                "month": month,
                "totalDayInMonth": 0,
                "createAt": createTime,
                "updateAt": createTime
            ],
            merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
            completion: { error in
                completionAction(error)
            })
        }
    }

    // 配列が欲しいので、yearが一致したものでmonthで並び替えたものを取ってくる？ → これやってみる
    static func showFolderDateForFirestore(
                                           completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            // whereField("year", イコールyear)は今の所なくても大丈夫そう
                // 今の所, order(month)のみでいけてる
            // "users/\(user.uid)/folderSections/folderDates/folderDate"
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").order(by: "month", descending: true).addSnapshotListener( {(querySnapshot, error) in
                completionAction(querySnapshot, error)
            })
        }
    }

    // これはupdateとして必要
    static func updateTotalDayInMonth(folderDate: FolderDate,
                                         fileDatesCount: Int,
                                         completionAction: @escaping (Error?) -> Void) {
        if fileDatesCount == 0 {
            return
        }
        if let user = Auth.auth().currentUser {
            // 【変更後】
            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").document(folderDate.id).setData([
                "totalDayInMonth": fileDatesCount,
                "updateAt": FieldValue.serverTimestamp()
            ],
            merge: true,
            completion: { error in
                completionAction(error)
            })
            // 【変更前】
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").document(folderDate.id).updateData([
//                "totalDayInMonth": fileDatesCount,
//                "updateAt": FieldValue.serverTimestamp()
//            ], completion: { error in
//                completionAction(error)
//            })
        }
    }

    // 今の所ボツ
//    static func calculateTotalDayInYearSection(year: Int,
//                                               folderDates: [FolderDate],
//                                               completionAction: @escaping (Error?) -> Void) {
//        // 共通したyearの一意な月のFileDatesをもつドキュメントたちを持ってくる
//        if let user = Auth.auth().currentUser {
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates").whereField("year", isEqualTo: year)
//    //            var totalDay = 0 // 初期化
//    //            if folderDates.count != 0 {
//    //                for i in 0...folderDates.count-1 {
//    //                    totalDay += folderDates[i].fileDates.count
//    //                }
//    //            }
//        }
//    }
}

