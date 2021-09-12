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
    
    var isDone: Bool = false
    var todoArray: [Todo] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        User.getUserDataForFireStore(completionAction: { (snapshot, error) in
            if let snap = snapshot {
                if let data = snap.data() {
                    self.userNameLabel.text = data["name"] as? String // label.textと同じようにオプショナルの型として合わせる？
                }
            } else if let error = error {
                print("ユーザー名取得失敗: " + error.localizedDescription)
            }
        })
        
        showTodoListData()
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
    
    // do try catch 構文なので放置！！！！
    @IBAction func tapLogoutButton(_ sender: Any) {
        // ログイン済みかどうかを確認
        // ログインしていなかったら何もしない
        if Auth.auth().currentUser != nil {
            // ログアウトの処理
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
            isDone = false
            showTodoListData()
        case 1:
            isDone = true
            showTodoListData()
        // ないとエラーになるので定義
        default:
            isDone = false
            showTodoListData()
        }
    }
    
    func showTodoListData() {
        Todo.getTodoListDataForFirestore(isDone: self.isDone,
                                         completionAction: { (querySnapshot, error) in
                                            var todoList: [Todo] = []
                                            if let querySnapshot = querySnapshot {
                                                for doc in querySnapshot.documents {
                                                    let todo = Todo(doc: doc)
                                                    todoList.append(todo)
                                                    self.todoArray = todoList
                                                }
                                            } else if let error = error {
                                                print("TODO取得失敗: " + error.localizedDescription)
                                                self.todoArray = []
                                            }
                                            self.tableView.reloadData()
                                         })
    }
    
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard: UIStoryboard = self.storyboard!
        let next = storyboard.instantiateViewController(withIdentifier: "TodoEditViewController") as! TodoEditViewController
        next.todo = todoArray[indexPath.row]
        self.present(next, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // edit系のアクション
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit",
                                            handler: { (action: UIContextualAction,
                                                        view: UIView,
                                                        completion: (Bool) -> Void) in
                                                Todo.isDoneUpdate(todo: self.todoArray[indexPath.row],
                                                                  complectionAction: { error in
                                                                    if let error = error {
                                                                        FuncUtility.showErrorDialog(error: error,
                                                                                                    title: "Todo更新失敗",
                                                                                                    currentVC: self)
                                                                    } else {
                                                                        print("Todo更新成功")
                                                                        // updateした後に最新の情報を取ってきて表示する
                                                                        self.showTodoListData()
                                                                    }
                                                                  })
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
                                                Todo.delete(todo: self.todoArray[indexPath.row],
                                                            complectionAction: { error in
                                                                if let error = error {
                                                                    FuncUtility.showErrorDialog(error: error,
                                                                                                title: "Todo削除失敗",
                                                                                                currentVC: self)
                                                                } else {
                                                                    print("Todo削除成功")
                                                                    self.showTodoListData()
                                                                }
                                                            })
                                              })
        // 背景の設定
        deleteAction.backgroundColor = UIColor(red: 214/255.0, green: 69/255.0, blue: 65/255.0, alpha: 1)
        deleteAction.image = UIImage(systemName: "trash") // ゴミ箱にしたい
        
        // スワイプアクションとしてを追加してreturnで返す
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        // fullスワイプ時に挙動が起きないように制御
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = todoArray[indexPath.row].title
        return cell
    }
}
