//
//  TodoEditViewController.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/10.
//

import UIKit
import Firebase

final class TodoEditViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var isDoneLabel: UILabel!

    var todo: Todo!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = todo.title
        detailTextView.text = todo.detail

        switch todo.isDone {
        case false:
            isDoneLabel.text = "未完了"
            doneButton.setTitle("完了済みにする", for: .normal)
        default: // デフォルトはfalse以外？
            isDoneLabel.text = "完了"
            doneButton.setTitle("未完了にする", for: .normal)
        }
    }

    override func viewDidLayoutSubviews() {
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        detailTextView.layer.cornerRadius = 5.0
        detailTextView.layer.masksToBounds = true
    }

    @IBAction func tapEditButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            todo.title = title
            todo.detail = detail
            Todo.updateContentEditTapped(todo: self.todo,
                                         currentVC: self)
        }
    }

    // 本来はここでも最新のtextFieldの値を取ってきて変えた方がユーザー体験からするといい
    @IBAction func tapDoneButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            todo.title = title
            todo.detail = detail
            Todo.updateContentIsDoneTapped(todo: self.todo,
                                           currentVC: self)
        }
    }

    @IBAction func tapDeleteButton(_ sender: Any) {
        Todo.delete(todo: self.todo,
                    complectionAction: { error in
                        if let error = error {
                            FuncUtility.showErrorDialog(error: error,
                                                        title: "Todo削除失敗",
                                                        currentVC: self)
                        } else {
                            print("Todo削除成功")
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
    }

}
