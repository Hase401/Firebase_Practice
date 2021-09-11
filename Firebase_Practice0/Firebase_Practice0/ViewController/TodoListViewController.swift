//
//  TodoListViewController.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/10.
//

import UIKit
import Firebase

final class TodoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!

    // Firestoreから取得するTodoのid,title,detail,isDoneを入れる配列を用意
    // よくあるのはTodoモデルを作成してモデルでまとめて扱うパターン // 初学者向けに難しいコードを使いたくない
    var todoIdArray: [String] = []
    var todoTitleArray: [String] = []
    var todoDetailArray: [String] = []
    var todoIsDoneArray: [Bool] = []

    var isDone: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ログイン済みかどうか確認する
        // ログイン済みであればuserにログインしているユーザー情報が入る // 未ログインの場合はnil
        if let user = Auth.auth().currentUser {
            // firestoreからログインしているユーザー名の取得
            // Firestoreからある特定のデータを取得する場合はcollection("取得したいコレクション名").document("取得するID").getDocument
            // completionという引数名は自身の関数が終わった後に行う処理を渡すのに使われる引数名
            // getDocumentの処理が終わった後に呼ばれる処理をこの引数に渡してあげる
            // getDocumentは関数が成功した場合はDocumentSnapshot型の値を、失敗した場合はエラーを返す
            Firestore.firestore().collection("users").document(user.uid).getDocument(completion: { (snapshot, error) in
                // データの取得が成功ならsnapshotという変数にデータのスナップショットが入り、失敗すればerrorにエラー情報が入る
                if let snap = snapshot {
                    // 実際のデータとしてはsnapshot.data()に入っている
                    if let data = snap.data() {
                        // Firestoreの値はkey-valueの配列で保存されているので辞書のように使える
                        self.userNameLabel.text = data["name"] as? String
                    }
                } else if let error = error {
                    print("ユーザー名取得失敗: " + error.localizedDescription)
                }
            })



            // Firestoreから検索と並び替えを行い取得
            // 1.検索 whereField "isDone"についてisEqualToで検索
                // "isDone"(未完了、完了済み)というフィールドが画面の状態(未完了か完了済み)で検索
            // 2.並び替え order(by: "並び替えするフィールド名")
                // 降順に並び替える場合はorder(by: "createdAt",descending: true)
            // 3.複合クエリ // 検索、並び替えの二つ以上を併用する場合はその項目でindexを作成する必要がある
                // indexの作成は、FirebaseのConsole画面からできる
            // 4.getDocumentsとaddSnapshotListener
                // 複数のデータを取得する方法としてgetDocuments()とaddSnapshotListener()
                    // addSnapshotListenerがFirestore特有だが、Firestoreの更新を検知して複数取得の処理が走る
                    // 今回のTodoデータは作成・更新・削除は自分しか行わないため、あまりaddSnapshotListenerのうまみはない
                    // トーク機能などを作る時にかなり重宝
                    // 今回複数の処理なのでquerySnapshotという変数が返ってくる
            // 【疑問】今回getElementsだと上手くいかない？
            Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createAt").addSnapshotListener({ (querySnapshot, error) in
                print(querySnapshot)
                    if let querySnapshot = querySnapshot {
                        print(querySnapshot.documents)
                        // Firestoreから取得したデータを入れる配列を用意してfor文で追加する
                        var idArray:[String] = [] // ドキュメントのID？
                        var titleArray:[String] = []
                        var detailArray:[String] = []
                        var isDoneArray:[Bool] = []
                        for doc in querySnapshot.documents {
                            let data = doc.data()
                            idArray.append(doc.documentID)
                            titleArray.append(data["title"] as! String)
                            detailArray.append(data["detail"] as! String)
                            isDoneArray.append(data["isDone"] as! Bool)
                        }

                        // classで用意した変数に代入してtableViewをリロード
                        self.todoIdArray = idArray
                        self.todoTitleArray = titleArray
                        self.todoDetailArray = detailArray
                        self.todoIsDoneArray = isDoneArray
                        print(self.todoTitleArray)

                        self.tableView.reloadData()
                    } else if let error = error {
                        // indexがコレクショングループではなくコレクションにしたらこれがなくなってくれた
                        print("TODO取得失敗: " + error.localizedDescription)
                    }
                })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func tapAddButton(_ sender: Any) {
        FuncUtility.presentNextViewController(currentVC: self,
                                              withNextVCIdentifier: "TodoAddViewController")
    }

    @IBAction func tapLogoutButton(_ sender: Any) {
       // ログイン済みかどうかを確認 // ログインしていなかったら何もしない
        if Auth.auth().currentUser != nil {
            // ログアウトの処理
            // do try catch 構文なので保留！！！！！！！！！！
            do {
                try Auth.auth().signOut()
                print("ログアウト完了")
                FuncUtility.presentNextViewController(currentVC: self,
                                                      withNextVCIdentifier: "ViewController")
            } catch let error as NSError {
                FuncUtility.showErrorDialog(error: error,
                                            title: "ログアウト失敗",
                                            currentVC: self)
            }
        }
    }

    @IBAction func changeDoneControl(_ sender: UISegmentedControl) {
        // 未完了、完了済みを切り替えた時の処理
        switch sender.selectedSegmentIndex {
        case 0:
            // 未完了、完了を切り替える
            isDone = false
            // firestoreからデータを取得
            getTodoDataForFirestore()
        case 1:
            isDone = true
            getTodoDataForFirestore()
        // ないとエラーになるので定義している
        default:
            isDone = false
            getTodoDataForFirestore()
        }
    }

    func getTodoDataForFirestore() {
        if let user = Auth.auth().currentUser {
            // 今回検索と並び替えの２つ以上を併用しているのでindexを作る必要がある
            // 【疑問】でもコレクショングループと単なるコレクションがあるから何が違うんだろう
                // 恐らく使えるクエリのスコープが変わってくる？
            Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createAt").addSnapshotListener({ (querySnapshot, error) in
                print(querySnapshot)
                    if let querySnapshot = querySnapshot {
                        print(querySnapshot.documents)
                        // Firestoreから取得したデータを入れる配列を用意してfor文で追加する
                        var idArray:[String] = [] // ドキュメントのID？
                        var titleArray:[String] = []
                        var detailArray:[String] = []
                        var isDoneArray:[Bool] = []
                        for doc in querySnapshot.documents {
                            let data = doc.data()
                            idArray.append(doc.documentID)
                            titleArray.append(data["title"] as! String)
                            detailArray.append(data["detail"] as! String)
                            isDoneArray.append(data["isDone"] as! Bool)
                        }

                        // classで用意した変数に代入してtableViewをリロード
                        self.todoIdArray = idArray
                        self.todoTitleArray = titleArray
                        self.todoDetailArray = detailArray
                        self.todoIsDoneArray = isDoneArray
                        print(self.todoTitleArray)

                        self.tableView.reloadData()
                    } else if let error = error {
                        // indexがコレクショングループではなくコレクションにしたらこれがなくなってくれた
                        print("TODO取得失敗: " + error.localizedDescription)
                    }
                })
        }
    }

}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let next = storyboard.instantiateViewController(withIdentifier: "TodoEditViewController") as! TodoEditViewController
        next.todoId = todoIdArray[indexPath.row]
        next.todoTitle = todoTitleArray[indexPath.row]
        next.todoDetail = todoDetailArray[indexPath.row]
        next.todoIsDone = todoIsDoneArray[indexPath.row]
        self.present(next, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // edit系のアクション
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit",
                                            handler: { (action: UIContextualAction,
                                                        view: UIView,
                                                        completion: (Bool) -> Void) in
                                                if let user = Auth.auth().currentUser {
                                                    Firestore.firestore().collection("users/\(user.uid)/todos").document(self.todoIdArray[indexPath.row]).updateData([
                                                        "isDone": !self.todoIsDoneArray[indexPath.row],
                                                        "updateAt": FieldValue.serverTimestamp()
                                                    ], completion: { error in
                                                        if let error = error {
                                                            FuncUtility.showErrorDialog(error: error,
                                                                                        title: "ToDo更新失敗",
                                                                                        currentVC: self)
                                                        } else {
                                                            print("TODO更新成功")
                                                            // 最新の情報としてリロードするが、これでsegmentIndexが条件に入っていないため、難しくなっている！！
                                                                // まずは、リファレンスや責務を分けられるようになってから解決しよう
                                                            self.getTodoDataForFirestore()
                                                        }
                                                    })
                                                }
                                            })
        // 背景の設定
        editAction.backgroundColor = UIColor(red: 101/255.0, green: 198/255.0, blue: 187/255.0, alpha: 1)
        // controlの値によって表示するアイコンを切り替え
        switch isDone {
        case true:
            editAction.image = UIImage(systemName: "arrowshape.turn.up.left")
        default:
            editAction.image = UIImage(systemName: "checkmark")
        }

        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Delete",
                                              handler: { (action: UIContextualAction,
                                                          view: UIView,
                                                          completion: (Bool) -> Void) in
                                                if let user = Auth.auth().currentUser {
                                                    Firestore.firestore().collection("user/\(user.uid)/todos").document(self.todoIdArray[indexPath.row]).delete() { error in
                                                        if let error = error {
                                                            FuncUtility.showErrorDialog(error: error,
                                                                                        title: "ToDo削除失敗",
                                                                                        currentVC: self)
                                                        } else {
                                                            print("TODO削除成功")
                                                            // 最新の情報としてリロードする
                                                            self.getTodoDataForFirestore()
                                                        }
                                                    }
                                                }
                                              })
        // 背景の設定
        deleteAction.backgroundColor = UIColor(red: 214/255.0, green: 69/255.0, blue: 65/255.0, alpha: 1)
        deleteAction.image = UIImage(systemName: "clear") // ゴミ箱にしたい

        // スワイプアクションとしてを追加してreturnで返す
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        // fullスワイプ時に挙動が起きないように制御
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }

}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoTitleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = todoTitleArray[indexPath.row]
        return cell
    }
}
