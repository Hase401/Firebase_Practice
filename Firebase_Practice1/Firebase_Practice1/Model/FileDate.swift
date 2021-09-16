//
//  FileDate.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import Foundation
import Firebase

// FileDates(サブコレクション)
    // fileDate.id(ドキュメント)
        // month(フィールド)
        // day(フィールド)
        // week(フィールド)
        // createaAt(フィールド)
        // （実際には次に RoutingDays(同じようなドキュメントとサブコレクションの関係性が続く)）

//final class FileDate: NSObject {
//    var id: String
//    var month: Int
//    var day: Int
//    var week: String
//    var createAt: Date
//
//    init(doc: QueryDocumentSnapshot) {
//        self.id = doc.documentID
//
//        let data = doc.data()
//        self.month = data["month"] as! Int
//        self.day = data["day"] as! Int
//        self.week = data["week"] as! String
//        let createAtTimestamp = data["createAt"] as? Timestamp
//
//        if let createAt = createAtTimestamp {
//            self.createAt = createAt.dateValue() // Timestamp型からDate型に変換
//        } else {
//            // もしnilだった場合
//            self.createAt = Date()
//        }
//    }
//
////    static func createFolderDateToFirestore(year: Int,
////                                            month: Int) {
////        let createTime = FieldValue.serverTimestamp()
////        // documentはないので空のままでいい？
////        // 【曖昧】コレクションはこれで定義して理想通りになっているか失敗しててもいいから実際にコンソールで検証するべきだな。。。
////        Firestore.firestore().collection("folderLists/folderList/folderSections/folderSection/folderDates").document().setData([
////            "year": year,
////            "month": month,
////            "createAt": createTime
////        ],
////        merge: true, // trueならデータがある時はupdateを行い、データがない場合はcreateを行う
////        completion: { error in
////            if let error = error {
////                print("Todoの作成失敗" + error.localizedDescription)
////            } else {
////                print("Todoの作成成功")
////            }
////        })
////    }
////
////    // 配列が欲しいので、yearが一致したものでmonthで並び替えたものを取ってくる？
////    static func showFolderDateForFirestore(year: Int,
////                                           completionAction: @escaping (QuerySnapshot?, Error?) -> Void) {
////        Firestore.firestore().collection("folderLists/folderList/folderSections/folderSection/folderDates").whereField("year", isEqualTo: year).order(by: "month", descending: false).addSnapshotListener( {(querySnapshot, error) in
////            completionAction(querySnapshot, error)
////        })
////    }
//}
//
