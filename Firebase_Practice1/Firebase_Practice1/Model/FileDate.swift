//
//  FileDate.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct FileDate: Codable {
    @DocumentID var id: String?
    var year: Int
    var month: Int
    var day: Int
    var week: String
    var createdAt: Timestamp?
    var updatedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
      case year
      case month
      case day
      case week
      case createdAt
      case updatedAt
    }

    // エンコード処理
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.year, forKey: .year)
        try container.encode(self.month, forKey: .month)
        try container.encode(self.day, forKey: .day)
        try container.encode(self.week, forKey: .week)
        // 初期値がnilのときのみ設定する
        if self.createdAt == nil {
            try container.encode(FieldValue.serverTimestamp(), forKey: .createdAt)
        }
        try container.encode(FieldValue.serverTimestamp(), forKey: .updatedAt)
    }
}


// FileDates(サブコレクション)
    // fileDate.id(ドキュメント)
        // month(フィールド)
        // day(フィールド)
        // week(フィールド)
        // createaAt(フィールド)
        // （実際には次に RoutingDays(同じようなドキュメントとサブコレクションの関係性が続く)）

//final class FileDate: NSObject {
//    var id: String
//    var year: Int
//    var month: Int
//    var day: Int
//    var week: String
//    var createAt: Date
//
//    init(doc: QueryDocumentSnapshot) {
//        self.id = doc.documentID
//
//        let data = doc.data()
//        self.year = data["year"] as? Int ?? 0
//        self.month = data["month"] as? Int ?? 0
//        self.day = data["day"] as? Int ?? 0
//        self.week = data["week"] as? String ?? ""
//        let createAtTimestamp = data["createAt"] as? Timestamp
//        if let createAt = createAtTimestamp {
//            self.createAt = createAt.dateValue() // Timestamp型からDate型に変換
//        } else {
//            self.createAt = Date()
//        }
//    }
//
//    static func createFileDateToFirestore(folderDate: FolderDate,
//                                          day: Int,
//                                          week: String,
//                                          completionAction: @escaping (Error?) -> Void) {
//        if let user = Auth.auth().currentUser {
//            let createTime = FieldValue.serverTimestamp()
//            // documentはないので空のままでいい？
//            // 【曖昧】コレクションはこれで定義して理想通りになっているか失敗しててもいいから実際にコンソールで検証するべきだな。。。
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates/\(folderDate.id)/FileDates").document().setData([
//                "year": folderDate.year,
//                "month": folderDate.month,
//                "day": day,
//                "week": week,
//                "createAt": createTime
//            ],
//            merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
//            completion: { error in
//                completionAction(error)
//            })
//        }
//    }
//
////    // 配列が欲しいので、yearが一致したものでmonthで並び替えたものを取ってくる？
//    static func showFileDateForFirestore(folderDate: FolderDate,
//                                         completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
//        if let user = Auth.auth().currentUser {
//            Firestore.firestore().collection("Users/\(user.uid)/FolderSections/folderSection/FolderDates/\(folderDate.id)/FileDates").order(by: "day", descending: true).addSnapshotListener( {(querySnapshot, error) in
//                completionAction(querySnapshot, error)
//            })
//        }
//    }
//}

