//
//  FolderDateRepository.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/21.
//

import Foundation
import Firebase

final class FolderDateRepository {
}

extension FolderDateRepository {
    func addFolderDate(folderDate: FolderDate, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        var data: [String: Any]!
        do {
            // エンコード処理
            data = try Firestore.Encoder().encode(folderDate)
        } catch {
            fatalError(error.localizedDescription)
        }
        // 【パターン②】
        let documentReference: DocumentReference = db.collection("users/\(user.uid)/folderSections/folderSection/folderDates").document()
        documentReference.setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        // 【パターン①】
        // コレクションにエンコードしたデータを追加
//        var documentReference: DocumentReference? = nil
//        documentReference = db.collection("users/\(user.uid)/folderSections/folderSection/folderDates").addDocument(data: data) { error in
//            if let error = error {
//                print("Error adding document:", error.localizedDescription)
//            } else {
//                print("Document added with ID:", documentReference!.documentID)
//            }
//        }
    }

    // 【パターン②】
    func fetchFolderDate(completion: @escaping (Result<[Int: [FolderDate]], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        // 【疑問】サブコレクションのやり方は、一回別のドキュメントを挟めばよさそう？
        let collectionReference = db.collection("users/\(user.uid)/folderSections/folderSection/folderDate").order(by: "month", descending: true)
        collectionReference.getDocuments { (querySnapshot, error) in
            if let error = error {
//                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else {
//                completion(.failure(NetworkError.unknown))
                return
            }
            var folderDateDictionary: [Int: [FolderDate]] = [:]
            do {
                for document in querySnapshot.documents {
                    let folderDate: FolderDate = try Firestore.Decoder().decode(FolderDate.self, from: document.data())
                    let year = folderDate.year
                    if folderDateDictionary[year] == nil {
                        folderDateDictionary[year] = [] // yearに対応したものだけが入る // classなのになぜDBに保存されているからデータが共有化されていないのか？
                    }
                    folderDateDictionary[year]?.append(folderDate)
                }
                completion(.success(folderDateDictionary))
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    // 【パターン①】
//    func fetchFolderDate(completion: @escaping (Result<[FolderDate], Error>) -> Void) {
//        guard let user = Auth.auth().currentUser else { return }
//        let db = Firestore.firestore()
//        // 【疑問】サブコレクションのやり方は、一回別のドキュメントを挟めばよさそう？
//        let collectionReference = db.collection("users/\(user.uid)/folderSections/folderSection/folderDate").order(by: "month", descending: true)
//        collectionReference.getDocuments { (querySnapshot, error) in
//            if let error = error {
////                print(error.localizedDescription)
//                completion(.failure(error))
//                return
//            }
//            guard let querySnapshot = querySnapshot else {
////                completion(.failure(NetworkError.unknown))
//                return
//            }
//            var folderDates: [FolderDate] = []
//            do {
//                for document in querySnapshot.documents {
//                    // key:value形式のデータをDecodeする
//                    let folderDate: FolderDate = try Firestore.Decoder().decode(FolderDate.self, from: document.data())
//                    folderDates.append(folderDate)
//                }
//                completion(.success(folderDates))
//            }
//            catch {
//                fatalError(error.localizedDescription)
//            }
//        }
//    }

    // 【保留】
    // 【疑問】FolderDateではなく、folderDateIdだけでいい？
    // 【解決】今回はプロパティとしてidを持っていたほうが楽になる
//    func updateTotalDayInMonth(folderDateId: String,
//                                         fileDatesCount: Int,
//                                         completionAction: @escaping (Error?) -> Void) {
//        if fileDatesCount == 0 {
//            return
//        }
//        guard let user = Auth.auth().currentUser else { return }
//        let db = Firestore.firestore()
//        let documentReference = db.collection("users/\(user.uid)/folderSections/folderSection/folderDate").document(folderDateId)
//        documentReference.updateData([
//            "totalDayInMonth": fileDatesCount,
//            "updateAt": FieldValue.serverTimestamp()
//        ]) { error in
//            completionAction(error)
//        }
//
//
////        if let user = Auth.auth().currentUser {
////            // 【変更後】
////            Firestore.firestore().collection("Users/\(user.uid)/folderSections/folderSection/folderDates").document(folderDateId).setData([
////                "totalDayInMonth": fileDatesCount,
////                "updateAt": FieldValue.serverTimestamp()
////            ],
////            merge: true,
////            completion: { error in
////                completionAction(error)
////            })
////        }
//    }
}
