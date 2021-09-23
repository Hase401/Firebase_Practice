//
//  FileDateRepository.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/22.
//

import Foundation
import Firebase

final class FileDateRepository {
}

extension FileDateRepository {
    func addFileDate(folderDate: FolderDate, fileDate: FileDate,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        // 【曖昧】本来はStringとして持ってきたい？
        guard let folderDateId = folderDate.id else { return }
        let db = Firestore.firestore()
        var data: [String: Any]!
        do {
            data = try Firestore.Encoder().encode(fileDate)
        } catch {
            fatalError(error.localizedDescription)
        }
        let documentReference: DocumentReference = db.collection("users/\(user.uid)/folderSections").document("folderSection").collection("folderDates").document(folderDateId).collection("fileDates").document()
        documentReference.setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchFileDate(folderDate: FolderDate, completion: @escaping (Result<[FileDate], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        guard let folderDateId = folderDate.id else { return }
        let db = Firestore.firestore()
        let collectionReference = db.collection("users/\(user.uid)/folderSections").document("folderSection").collection("folderDates").document(folderDateId).collection("fileDates").order(by: "day", descending: true)
        collectionReference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else {
//                completion(.failure(NetworkError.unknown))
                return
            }
            var fileDates: [FileDate] = []
            fileDates = querySnapshot.documents.compactMap { queryDocumentSnapshot -> FileDate? in
                // 【疑問】なぜ、try?なのか？
                var fileDate = try? queryDocumentSnapshot.data(as: FileDate.self)
                fileDate?.id = queryDocumentSnapshot.documentID // 自動でやってくれないので無理やり追加する
                // 【疑問】結局compactMapでnilだったら弾かれている？playgroundで確認してみる
                return fileDate
            }
            completion(.success(fileDates))
        }
    }
}
