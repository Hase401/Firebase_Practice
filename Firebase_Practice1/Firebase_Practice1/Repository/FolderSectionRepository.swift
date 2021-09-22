//
//  FolderSectionRepository.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/21.
//

import Foundation
import Firebase

final class FolderSectionRepositroy {
}

extension FolderSectionRepositroy {
    // toggleIsShowedさせるときにDocumentReferenceのIdを使いたいのでDoucmentReferenceを返す
        // プロパティにidをいれたのでDocumentReferenceを返さなくても良くなったのでVoidにしておく
    func addFolderSection(folderSection: FolderSection, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        var data: [String: Any]!
        do {
            // エンコード処理
            data = try Firestore.Encoder().encode(folderSection)
        } catch {
            fatalError(error.localizedDescription)
        }
        // コレクションにエンコードしたデータを追加
        // 【疑問】リファレンスはいるのか？
        // 【解決】他のメソッドでIdを使うためにcollectionReferenceを返す
//        let collectionReference: CollectionReference = db.collection("users/\(user.uid)/folderSections")
//        collectionReference.addDocument(data: data) { error in
//            if let error = error {
//                //                print("FolderSectionの追加失敗", error.localizedDescription)
//                completion(.failure(error))
//            } else {
//                //                print("FolderSectionの追加成功", documentReference!.documentID)
//                completion(.success((collectionReference)))
//            }
//        }

        // エンコードしたdataを使う
        let documentReference: DocumentReference = db.collection("users/\(user.uid)/folderSections").document()
        documentReference.setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        // これだとfromの型がEncodableなのでCodableを使っている意味がなくなる
//        documentReference.setData(from: data, merge: true) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success((collectionReference)))
//            }
//        }


//        do {
//            _ = try db.collection("Users/\(user.uid)/FolderSections").addDocument(from: folderSection)
//        }
//        catch {
//            print("Error", error.localizedDescription)
//        }
    }

    // 【疑問】updatedAtの更新はどうすればいいのか？
    // 【疑問】FolderSectionを渡すよりも1つ1つ渡した方がシンプルだし可読性も上がりやすい？
    func toggleIsShowed(folderSection: FolderSection,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        guard let folderSectionId = folderSection.id else { return }
        let db = Firestore.firestore()
        let documentReference = db.collection("users/\(user.uid)/folderSections").document(folderSectionId)
        documentReference.updateData([
            // 【疑問】前はクラスだったからtoggleしなくても変わってたのかも？
            "isShowed": folderSection.isShowed,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // 【疑問】できればtoggleはRepositoryでさせたい
                completion(.success(()))
            }
        }
    }

    func fetchFolderSection(completion: @escaping (Result<[FolderSection], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let collectionReference = db.collection("users/\(user.uid)/folderSections").order(by: "year", descending: true)
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
            var folderSections: [FolderSection] = []
//            folderSections = snapshot.documents.compactMap { queryDocumentSnapshot -> FolderSection? in
//                return try? queryDocumentSnapshot.data(as: FolderSection.self)
//            }
            do {
                for document in querySnapshot.documents {
                    // key:value形式のデータをDecodeする
                    // このときにfolderSecitonのidプロパティにdocumentIdが自動で入っているように設定した
                    let folderSection: FolderSection = try Firestore.Decoder().decode(FolderSection.self, from: document.data())
                    folderSections.append(folderSection)
                }
                completion(.success(folderSections))
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    // 【保留】
    // FolderSection のプロバティとして[FolderDate]があるとキレイだったかも
//    func calculateTotalDayInYear(folderSection: FolderSection,
//                                               folderDates: [FolderDate], // これのtotalDayInMonthをfor文で回して計算すればいいかも！
////                                               totalDay: Int,
//                                               completion: @escaping (Result<Void, Error>) -> Void) {
////        print("folderDates:", folderDates)
////        print("folderDates.count:", folderDates.count)
//        if folderDates.count == 0 {
//            return // もともとtotalDayInYearSectionは0だから
//        }
//        guard let user = Auth.auth().currentUser else { return }
//        guard let folderSectionId = folderSection.id else { return }
//        var totalDay: Int = 0
//        for i in 0...folderDates.count-1 {
//            totalDay += folderDates[i].totalDayInMonth
//        }
////        print("totalDay:", totalDay)
//        let db = Firestore.firestore()
//        let documentReference = db.collection("users/\(user.uid)/folderSections").document(folderSectionId)
//        documentReference.updateData([
//            "totalDayInYear": totalDay,
//            "updatedAt": FieldValue.serverTimestamp()
//        ]) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }


//    static func fetchFolderSection(completion: (([FolderSection]) -> Void)? = nil) {
//        guard let user = Auth.auth().currentUser else { return }
//        let db = Firestore.firestore()
//        // fetchではドキュメントが必要
//        let _completion: ((QuerySnapshot?, Error?) -> Void) = { (querySnapshot, error) in
//
//            var folderSections: [FolderSection] = []
//
//            if let error = error {
//                print("Error", error.localizedDescription)
//                completion?(folderSections)
//                return
//            }
//            guard let documents = querySnapshot?.documents else { return }
//
//            folderSections = documents.compactMap { queryDocumentSnapshot -> FolderSection? in
//                return try? queryDocumentSnapshot.data(as: FolderSection.self)
//            }
//
//            completion?(folderSections)
//        }
//
//        //全部終わるまで待つ？
//        db.collection("Users/\(user.uid)/FolderSections").order(by: "year", descending: true).getDocuments(completion: _completion)
//    }
}
