//
//  FileViewController.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//
//
//import UIKit
//
//final class FileViewController: UIViewController {
//    private let tableView: UITableView = {
//        let tableView = UITableView(frame: .zero,
//                                    style: .insetGrouped)
//        tableView.register(FileTableViewCell.nib(),
//                           forCellReuseIdentifier: FileTableViewCell.identifier)
//        return tableView
//    }()
//    private var fileButton = MyButton(frame: .zero)
//    private var label = UILabel(frame: .zero) // 無理180にやり合わせる
//
//    static func instantiate(folderDate: FolderDate,
//                            addFile: @escaping ([FileDate]) -> Void) -> FileViewController {
//        guard let vc = UIStoryboard(name: "File",
//                                    bundle: nil).instantiateInitialViewController() as? FileViewController else {
//            fatalError("FileViewControllerが見つかりません")
//        }
//        vc.folderDate = folderDate
//        vc.addFileHandler = addFile
//        return vc
//    }
//
//    private var folderDate: FolderDate! // !は使わない方がいい？ // 選ばれたyearとmonthを使う用
//    private var addFileHandler: ([FileDate]) -> Void = { _ in }
////    private var fileDates: [FileDate] = [] // folderDate内に[FileDate]を作ったのでそっちを使うように変更
//
//    private var dayArrayChoosed: [String] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = ThemeColor.backgroundColor
//
//        setupNC()
//        setupTableView()
//        setupButton()
//
//        // 毎回ユーザー側の情報を入れてあげる // 保留
//    }
//
//    private func setupNC() {
//        self.navigationItem.title = String(folderDate.year)+"年"+String(folderDate.month)+"月"
//        self.navigationItem.largeTitleDisplayMode = .always
//        self.navigationController?.navigationBar.tintColor = ThemeColor.mainColor
//        let image = UIImage(systemName: "pin.fill")
//        let rightButton = UIBarButtonItem(image: image,
//                                          style: .done,
//                                          target: self,
//                                          action: #selector(showModalButtonTapped(_:)))
//        rightButton.tintColor = ThemeColor.mainColor
//        self.navigationItem.rightBarButtonItem = rightButton
//    }
//    @objc func showModalButtonTapped(_ sender: UIButton) {
////        let routingTemplateVC = RoutingTemplateViewController.instantiate()
////        let nc = UINavigationController(rootViewController: routingTemplateVC)
////        nc.modalPresentationStyle = .fullScreen
////        self.present(nc, animated: true, completion: nil)
//    }
//
//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.tableFooterView = UIView()
//        tableView.backgroundColor = ThemeColor.backgroundColor
//        tableView.frame = view.bounds // AutoLayoutに変更したい？ // 広告使うのにどのくらいのbuttomの高さがいるのか？
//    }
//
//    private func setupButton() {
//        let image = UIImage(systemName: "doc.badge.plus",
//                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 26))
//        fileButton.setImage(image, for: .normal)
//        fileButton.addTarget(self, action: #selector(addFileButtonTapped), for: .touchUpInside)
//        view.addSubview(fileButton)
//        NSLayoutConstraint.activate([
//            // width
//            fileButton.widthAnchor.constraint(equalToConstant: 50),
//            // height
//            fileButton.heightAnchor.constraint(equalToConstant: 50),
//            // horizontal(X)
//            fileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            // vertical(Y)
//            fileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
//        ])
//    }
//    @objc func addFileButtonTapped() {
//        dayArrayChoosed = []
//        let calendar = Calendar.current
//        let today = Date()
//        let dayFormat = DateFormatter()
//        dayFormat.dateFormat = "yyyy/MM/dd/EEEE"
//        dayFormat.locale = Locale(identifier: "ja_JP")
////        dayFormat.setTemplate(.date)
//        guard let tomorrow = calendar.date(byAdding: .day,
//                                         value: 1,
//                                         to: calendar.startOfDay(for: today)) else { return }
//        let tomorrowDate = dayFormat.string(from: tomorrow)
//        let todayDate = dayFormat.string(from: today)
//        guard let yesterday = calendar.date(byAdding: .day,
//                                       value: -1,
//                                       to: calendar.startOfDay(for: today)) else { return }
//        let yesterdayDate = dayFormat.string(from: yesterday)
//        dayArrayChoosed = [
//            tomorrowDate, todayDate, yesterdayDate
//        ]
//
//        let title = "日付を選択してください"
//        let message = "\n\n\n\n\n\n\n\n" // pickerViewよりも広ければ一応問題なく動く
//        let actionSheet = UIAlertController(title: title,
//                                            message: message,
//                                            preferredStyle: UIAlertController.Style.actionSheet)
//        let pickerView = UIPickerView(frame: CGRect(x: 0,
//                                                    y: 20, // 自動で決めないといけない
//                                                    width: actionSheet.view.bounds.width*0.955, // ここをプロパティを用いて設定したいが、、
//                                                    height: 180)) // 合わせるのが面倒くさい。。。
//        label.frame = CGRect(x: 0,
//                             y: 166,
//                             width: actionSheet.view.bounds.width*0.955,
//                             height: 14) // 無理180にやり合わせる
//        label.textColor = ThemeColor.alertColor
//        label.textAlignment = NSTextAlignment.center
//        label.font = UIFont.systemFont(ofSize: 14)
//        pickerView.addSubview(label)
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        actionSheet.view.addSubview(pickerView)
//        pickerView.selectRow(1, inComponent: 0, animated: true)
//        changeErrorTextLabel(label: label, dateSelected: todayDate)
//        let newFileByTemplate = UIAlertAction(title: "テンプレートから新規作成",
//                               style: UIAlertAction.Style.default,
//                               handler: { (action: UIAlertAction!) in
//                                print("OK！テンプレートから作成します！")
//                                let dateSelected = self.dayArrayChoosed[pickerView.selectedRow(inComponent: 0)]
//                                let dateElements = dateSelected.components(separatedBy: "/")
//                                let year = Int(dateElements[0]) ?? 0
//                                let month = Int(dateElements[1]) ?? 0
//                                let day = Int(dateElements[2]) ?? 0
//                                let week = dateElements[3].prefix(1) // 1だと完全なstringにならない
//                                // yearが違ったらreturnで返す
//                                if year != self.folderDate.year {
//                                    return
//                                }
//                                // monthが違ったらreturnで返す
//                                if month != self.folderDate.month {
//                                    return
//                                }
//                                if self.folderDate.fileDates.count != 0 {
//                                    for i in 0...self.folderDate.fileDates.count-1 {
//                                        if day == self.folderDate.fileDates[i].day {
//                                            return
//                                        }
//                                    }
//                                }
//
//                                // 保留！！！！！！！！！！！！
////                                let newFile = FileDate(month: self.folderDate.month, day: day, week: String(week), routingDay: RoutingDay.templateRoutingDay)
////                                self.folderDate.fileDates.append(newFile)
////                                self.folderDate.fileDates.sort {$0.day > $1.day} // 管理したい
////                                self.tableView.reloadData()
////                                self.addFileHandler(self.folderDate.fileDates) // appendしたら忘れない
////
////                                let routingVC = RoutingViewController.instantiate(fileDate: newFile)
//////                                let routingVC = RoutingViewController.instantiate(fileDate: newFile,
//////                                                                                  isTemplate: true)
////                                self.navigationController?.pushViewController(routingVC, animated: true)
////                                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "\(self.folderDate.year)",
////                                                                                        style: .done,
////                                                                                        target: nil,
////                                                                                        action: nil)
//
//                               })
//        let close = UIAlertAction(title: "閉じる",
//                                  style: UIAlertAction.Style.cancel,
//                                  handler: { (action: UIAlertAction!) in
//                                    print("閉じる")
//                                  })
//        actionSheet.addAction(newFileByTemplate)
////        actionSheet.addAction(newFile)
//        actionSheet.addAction(close)
//        self.present(actionSheet, animated: true)
//    }
//
//}
//
//extension FileViewController: UITableViewDelegate {
//    // 【重大問題】cellタップしたら今までの情報が消えているのでそれでも上手くいくような処理に変える
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        // 保留！！！！！！！そもそもCellがない
////        let routingVC = RoutingViewController.instantiate(fileDate: folderDate.fileDates[indexPath.row])
////        self.navigationController?.pushViewController(routingVC, animated: true)
////        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "\(folderDate.year)",
////                                                                style: .done,
////                                                                target: nil,
////                                                                action: nil)
//    }
//}
//
//extension FileViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        folderDate.fileDates.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let fileCell = tableView.dequeueReusableCell(withIdentifier: FileTableViewCell.identifier, for: indexPath) as? FileTableViewCell else {
//            fatalError("FileTableViewCellが返ってきてません")
//        }
//        fileCell.configure(fileDate: folderDate.fileDates[indexPath.row])
//        return fileCell
//    }
//
//
//}
//
//extension FileViewController: UIPickerViewDelegate {
//
//}
//
//extension FileViewController: UIPickerViewDataSource {
//    // UIPickerViewで必須
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        dayArrayChoosed.count
//    }
//
//    // UIPickerViewで任意
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        dayArrayChoosed[row]
//    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let dateSelected = dayArrayChoosed[row]
//        changeErrorTextLabel(label: label, dateSelected: dateSelected) // labelを渡せないのでクロージャーを使う
//    }
//    // 純粋に描写だけするlabelとstringを受け取ってやる？？これがクロージャーになるべき？
//    private func changeErrorTextLabel(label: UILabel, dateSelected: String) {
//        let dateElements = dateSelected.components(separatedBy: "/")
//        let year = Int(dateElements[0]) ?? 0
//        let month = Int(dateElements[1]) ?? 0
//        let day = Int(dateElements[2]) ?? 0
//        if year != self.folderDate.year {
//            // enumとかでエラー文作れたらいいな〜〜
//            label.text = "※正しい年のフォルダで作成してください"
//            return
//        }
//        if month != self.folderDate.month {
//            label.text = "※正しい月のフォルダで作成してください"
//            return
//        }
//        if self.folderDate.fileDates.count != 0 {
//            for i in 0...self.folderDate.fileDates.count-1 {
//                if day == self.folderDate.fileDates[i].day {
//                    label.text = "※すでにファイルが存在します"
//                    return
//                }
//            }
//        }
//        label.text = ""
//    }
//}
