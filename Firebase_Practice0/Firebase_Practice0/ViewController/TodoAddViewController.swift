//
//  TodoAddViewController.swift
//  Firebase_Practice0
//
//  Created by 長谷川孝太 on 2021/09/10.
//

import UIKit
import Firebase

final class TodoAddViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    override func viewDidLayoutSubviews() {
        // TextViewのレイアウトをTextFieldに合わせるためのコード
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        detailTextView.layer.cornerRadius = 5.0
        detailTextView.layer.masksToBounds = true
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            Todo.createTodoToFirestore(title: title,
                                       detail: detail,
                                       currentVC: self)
        }
    }
}
