//
//  FolderSection.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

struct FolderSection: Codable {
    // decode時にidプロパティにdocumentIdを自動で入れてくれる
    // encode時には、@DocumentIDがついているプロパティは無視される
        // 【疑問】自動化されていない。。。
    @DocumentID var id: String?
    var year: Int
    var totalDayInYear: Int = 0
    var isShowed: Bool = true
    var createdAt: Timestamp?
    var updatedAt: Timestamp?

    // Encode&Decodeする対象のメンバを指定
    enum CodingKeys: String, CodingKey {
//      case id
      case year
      case totalDayInYear
      case isShowed
      case createdAt
      case updatedAt
    }

    // エンコード処理
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
        try container.encode(self.year, forKey: .year)
        try container.encode(self.totalDayInYear, forKey: .totalDayInYear)
        try container.encode(self.isShowed, forKey: .isShowed)
        // 初期値がnilのときのみ設定する
        if self.createdAt == nil {
            try container.encode(FieldValue.serverTimestamp(), forKey: .createdAt)
        }
        try container.encode(FieldValue.serverTimestamp(), forKey: .updatedAt)
    }
}


// FolderSections(サブコレクション)
    // folderSection.id (ドキュメント)
        // year(フィールド)
        // totalDayInYearSection(フィールド)
        // isShowed(フィールド)
        // createAt(フィールド)
        // updateAt(フィールド)
        // FolderDates(サブコレクション) → 次のファイルへ

//final class FolderSection: NSObject {
//    var id: String
//    var year: Int
//    var totalDayInYearSection: Int
//    var isShowed: Bool
//    var createAt: Date
//    var updateAt: Date
//
//    // QueryDocumentSnapshotはQuerySnapshotに入っている1つ1つのドキュメント
//    init(doc: QueryDocumentSnapshot) {
//        self.id = doc.documentID
//
//        let data = doc.data() // !が付くQueryDocumentSnapshotにするとDocumentSnapshotになる
//        self.year = data["year"] as? Int ?? 0
//        self.totalDayInYearSection = data["totalDayInYearSection"] as? Int ?? 0
//        self.isShowed = data["isShowed"] as? Bool ?? true
//        let createAtTimestamp = data["createcAt"] as? Timestamp
//        let updateAtTimestamp = data["updateAt"] as? Timestamp
//        if let createAt = createAtTimestamp,
//           let updateAt = updateAtTimestamp {
//            self.createAt = createAt.dateValue() // Timestamp型からDate型に変換
//            self.updateAt = updateAt.dateValue()
//        } else {
//            self.createAt = Date()
//            self.updateAt = Date()
//        }
//    }
//
//    static func createFolderSectionToFirestore(year: Int,
//                                               completionAction: @escaping (Error?) -> Void) {
//        if let user = Auth.auth().currentUser {
//            let createTime = FieldValue.serverTimestamp()
//            // 【曖昧】コレクションはこれで定義して理想通りになっているか失敗しててもいいから実際にコンソールで検証するべきだな。。。
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").document().setData([
//                "year": year,
//                "totalDayInYearSection": 0,
//                "isShowed": true,
//                "createAt": createTime,
//                "updateAt": createTime
//            ],
//            merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
//            completion: { error in
//                completionAction(error)
//            })
//        }
//    }
//
//    // 配列が欲しいので、yearで並び替えたものを取ってくる
//    // クエリが1つだけなので普通のSnapshotでgetDocumentメソッドで良さそう？
//    static func showFolderSectionsForFirestore(completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
//        if let user = Auth.auth().currentUser {
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").order(by: "year", descending: true).addSnapshotListener({(QuerySnapshot, error) in
//                completionAction(QuerySnapshot, error)
//            })
//        }
//    }
//
//    static func isShowedUpdate(folderSection: FolderSection,
//                             completionAction: @escaping (Error?) -> Void) {
//        if let user = Auth.auth().currentUser {
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").document(folderSection.id).updateData([
//                "isShowed": !folderSection.isShowed,
//                "updateAt": FieldValue.serverTimestamp()
//            ], completion: { error in
//                completionAction(error)
//            })
//        }
//    }
//
//    // これはupdateとして必要
//    static func calculateTotalDayInYearSection(folderSection: FolderSection,
//                                               folderDates: [FolderDate], // これのtotalDayInMonthをfor文で回して計算すればいいかも！
////                                               totalDay: Int,
//                                               completionAction: @escaping (Error?) -> Void) {
//        print("folderDates:", folderDates)
//        print("folderDates.count:", folderDates.count)
//        if folderDates.count == 0 {
//            return // もともとtotalDayInYearSectionは0だから
//        }
//        if let user = Auth.auth().currentUser {
//            var totalDay: Int = 0
//            for i in 0...folderDates.count-1 {
//                totalDay += folderDates[i].totalDayInMonth
//            }
//            print("totalDay:", totalDay)
//
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections").document(folderSection.id).updateData([
//                "totalDayInYearSection": totalDay,
//                "updateAt": FieldValue.serverTimestamp()
//            ], completion: { error in
//                completionAction(error)
//            })
//        }
//    }
//}
