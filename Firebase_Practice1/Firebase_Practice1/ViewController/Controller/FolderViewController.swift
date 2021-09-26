//
//  ViewController.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit
import FirebaseAuth

final class FolderViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var folderButton = MyButton(frame: .zero)
    private var label = UILabel(frame: .zero) // 無理180にやり合わせる

    static func instantiate() -> FolderViewController {
        guard let vc = UIStoryboard(name: "Folder", bundle: nil).instantiateInitialViewController() as? FolderViewController else {
            fatalError("FolderViewControllerが見つかりません")
        }
        return vc
    }

    private let folderSectionRepository = FolderSectionRepository()
    private let folderDateRepository = FolderDateRepository()

    private var yearArrayChoosed: [Int] = []
    private let monthArray = TimeArray.monthArray
    private var componentFiles: [[Int]] = []

    private var folderSections: [FolderSection] = []
    private var currentFolderDateDictionary: [Int: [FolderDate]] = [:]


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        showCurrentFolderSections {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.showCurrentFolderDates { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.backgroundColor

        setupNC()
        setupTableView() // setupNCの後にすることで最初からLargeTitlesが表示 // didSetでやらない
        setupButton()
    }
}

private extension FolderViewController {
    // 【課題】completionを自作したい // completion: (() -> Void)? = nil
    func showCurrentFolderSections(completion: (() -> Void)? = nil) {
        folderSectionRepository.fetchFolderSection { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let folderSections):
                self.folderSections = folderSections
                guard let completionHandler = completion else { return }
                completionHandler()
            case .failure(let error):
                FuncUtility.showErrorDialog(error: error, title: "データの読み込みに失敗しました", currentVC: self)
            }
        }
    }

    func showCurrentFolderDates(completion: (() -> Void)? = nil) {
        folderDateRepository.fetchFolderDate { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let folderDateDictionary):
                print("②folderDateDictionary:", folderDateDictionary)
                self.currentFolderDateDictionary = folderDateDictionary
                guard let completionHandler = completion else { return }
                completionHandler()
            case .failure(let error):
                FuncUtility.showErrorDialog(error: error, title: "データの読み込みに失敗しました", currentVC: self)
            }
        }
    }

    func setupNC() {
        self.navigationController?.navigationBar.barTintColor = ThemeColor.subColor
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = "記録一覧"
    }

    func setupTableView() {
        // style: getのみなのでstoryboardで変更
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ThemeColor.backgroundColor
        tableView.register(FolderHeaderView.nib(),
                           forHeaderFooterViewReuseIdentifier: FolderHeaderView.identifier)
        tableView.register(FolderTableViewCell.nib(),
                           forCellReuseIdentifier: FolderTableViewCell.identifier)
    }

    func setupButton() {
        let image = UIImage(systemName: "folder.badge.plus",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))
        folderButton.setImage(image, for: .normal)
        folderButton.addTarget(self, action: #selector(addFolderButtonTapped), for: .touchUpInside)
        view.addSubview(folderButton)
        NSLayoutConstraint.activate([
            // width
            folderButton.widthAnchor.constraint(equalToConstant: 50),
            // height
            folderButton.heightAnchor.constraint(equalToConstant: 50),
            // horizontal(X)
            folderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // vertical(Y)
            folderButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }

    // ここで更新処理
    func getCurrentYear() -> [Int] {
        let calendar = Calendar.current
        let yearFormat = DateFormatter()
        yearFormat.dateFormat = "yyyy"
        let today = Date()
        guard let next = calendar.date(byAdding: .year,
                                         value: 1,
                                         to: calendar.startOfDay(for: today)) else { return [] }
        let nextYear = Int(yearFormat.string(from: next)) ?? 0
        let todayYear = Int(yearFormat.string(from: today)) ?? 0
        guard let back = calendar.date(byAdding: .year,
                                       value: -1,
                                       to: calendar.startOfDay(for: today)) else { return [] }
        let backYear = Int(yearFormat.string(from: back)) ?? 0
        return [
            nextYear, todayYear, backYear
        ]
    }

    func checkCommonInYear(year: Int) -> Bool {
        if self.folderSections.count != 0 {
            for i in 0...self.folderSections.count-1 {
                if year == self.folderSections[i].year {
                    return true
                }
            }
        }
        return false
    }

    func checkCommonInMonthInYear(year: Int, month: Int) -> Bool {
        if let folderDates = self.currentFolderDateDictionary[year] {
            if folderDates.count != 0 {
                for i in 0...folderDates.count-1 {
                    if year == folderDates[i].year && month == folderDates[i].month {
                        return true
                    }
                }
            }
        }
        return false
    }

    // UIPickerViewDataSourceとは違う独自のメソッドなので分けたほうが後々見やすくなる
    func changeErrorTextLabel(label: UILabel, yearSelected: Int, monthSelected: Int) {
        let isCommonInYear = checkCommonInYear(year: yearSelected)
        let isCommonInMonth = checkCommonInMonthInYear(year: yearSelected, month: monthSelected)

        if isCommonInYear && isCommonInMonth {
            label.text = "※すでにフォルダが存在します"
            return
        }
        label.text = ""
    }
}

@objc extension FolderViewController {
    func addFolderButtonTapped() {
        yearArrayChoosed = getCurrentYear() // 更新処理はここでしかやらない
        componentFiles = [yearArrayChoosed, monthArray]
        let title = "年月を選択してください"
        let message = "\n\n\n\n\n\n\n\n" // pickerViewよりも広ければ一応問題なく動く
        let actionSheet = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: UIAlertController.Style.actionSheet)
        let pickerView = UIPickerView(frame: CGRect(x: 0,
                                                    y: 20, // 50
                                                    width: actionSheet.view.bounds.width*0.955, // ここをプロパティを用いて設定したいが、、
                                                    height: 180)) // 合わせるのが面倒くさい。。。 // 155
        label.frame = CGRect(x: 0,
                             y: 166,
                             width: actionSheet.view.bounds.width*0.955,
                             height: 14) // 無理180にやり合わせる
        label.textColor = ThemeColor.alertColor
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        pickerView.addSubview(label)
        pickerView.delegate = self
        pickerView.dataSource = self
        actionSheet.view.addSubview(pickerView)
        pickerView.selectRow(1, inComponent: 0, animated: true)
        // todayYearからyearArrayChoosed[1]に変更。。。 // まだキレイとだと思わないけど、明確な正解はないのかも
        changeErrorTextLabel(label: label, yearSelected: yearArrayChoosed[1], monthSelected: 1)
        let newFolder = UIAlertAction(title: "新規作成",
                               style: UIAlertAction.Style.default,
                               handler: { (action: UIAlertAction!) in
                                print("OK！ファイルを追加します！")
                                // 最初に使う定数がまとまっていると見やすい
                                let year = self.yearArrayChoosed[pickerView.selectedRow(inComponent: 0)]
                                let month = self.monthArray[pickerView.selectedRow(inComponent: 1)]
                                let isCommonInYear = self.checkCommonInYear(year: year)
                                let isCommonInMonth = self.checkCommonInMonthInYear(year: year, month: month)

                                if !isCommonInYear {
                                    let newFolderSection = FolderSection(year: year)
                                    self.folderSectionRepository.addFolderSection(folderSection: newFolderSection) { [weak self] response in
                                        guard let self = self else { return }
                                        switch response {
                                        case .success():
                                            self.currentFolderDateDictionary[year] = []
                                            self.showCurrentFolderSections { [weak self] in
                                                guard let self = self else { return }
                                                self.tableView.reloadData()
                                            }
                                        case .failure(let error):
                                            FuncUtility.showErrorDialog(error: error, title: "データの追加に失敗しました", currentVC: self)
                                        }
                                    }
                                }

                                if !isCommonInMonth {
                                    let newFolderDate = FolderDate(year: year, month: month)
                                    self.folderDateRepository.addFolderDate(folderDate: newFolderDate) { [weak self] response in
                                        guard let self = self else { return }
                                        switch response {
                                        case .success():
                                            self.showCurrentFolderDates { [weak self] in
                                                guard let self = self else { return }
                                                self.tableView.reloadData()
                                            }
                                        case .failure(let error):
                                            FuncUtility.showErrorDialog(error: error, title: "データの追加に失敗しました", currentVC: self)
                                        }
                                    }
                                }
                               })
        let close = UIAlertAction(title: "閉じる",
                                  style: UIAlertAction.Style.cancel,
                                  handler: nil)
        actionSheet.addAction(newFolder)
        actionSheet.addAction(close)
        self.present(actionSheet, animated: true)
    }
}

extension FolderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
    }
//
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let folderHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FolderHeaderView.identifier) as? FolderHeaderView else {
            fatalError("FolderHeaderViewが返ってきてません")
        }
        folderHeaderView.configure(folderSection: folderSections[section]) // folderDatesいらないから削除
        folderHeaderView.rotateImageView(folderSection: folderSections[section])
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(headerTapped(sender:)))
        folderHeaderView.addGestureRecognizer(gesture)
        folderHeaderView.tag = section
        return folderHeaderView
    }

    @objc func headerTapped(sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        folderSections[section].isShowed.toggle()
        folderSectionRepository.toggleIsShowed(folderSection: folderSections[section]) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success():
                self.tableView.beginUpdates()
                self.tableView.reloadSections([section], with: .fade)
                self.tableView.endUpdates()
            case .failure(let error):
                FuncUtility.showErrorDialog(error: error, title: "データの更新に失敗しました", currentVC: self)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currentFolderDates = currentFolderDateDictionary[folderSections[indexPath.section].year] else { return }
        let fileVC = FileViewController.instantiate(folderDate: currentFolderDates[indexPath.row], addFile: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.folderDateRepository.updateTotalDayInMonth(folderDate: currentFolderDates[indexPath.row], fileDatesCount: $0) { [weak self] response in
                // 【疑問】 [weak self] は必要？
                guard let self = self else { return }
                switch response {
                case .success():
                    print("①現在のcurrentFolderDates:", currentFolderDates)
                    let dispatchGroup = DispatchGroup()
                    // 【疑問】今回非同期処理が１つだけなのであまり関係ない？一応なくても動く
//                    let dispatchQueue = DispatchQueue(label: "queue") // 直列キュー / attibutes指定なし
//                    dispatchQueue.async(group: dispatchGroup) { [weak self] in
                    dispatchGroup.enter()
                    strongSelf.showCurrentFolderDates { [weak self] in
                        guard let self = self else { return }
                        self.tableView.reloadData()
                        dispatchGroup.leave()
                    }
//                    }
                    // 全ての処理で完了の合図としてleave()が呼ばれた後に、notify()メソッドで指定したクロージャが実行
                    dispatchGroup.notify(queue: .main) {
                        print("③All Process Done!")
                        // 【課題】非同期処理なので最新のものをとってこれていない
                        // 【疑問】strongSelfでもselfでもどっちでも動くけど、いいのか？
                        guard let nextCurrentFolderDates = strongSelf.currentFolderDateDictionary[strongSelf.folderSections[indexPath.section].year] else {
                            return
                        }
                        print("④更新後、最新のnextCurrentFolderDates:", nextCurrentFolderDates) // 確認用、結局新しいものをとってこれてきてない
                        strongSelf.folderSectionRepository.updateTotalDayInYear(folderSection: strongSelf.folderSections[indexPath.section], folderDates: nextCurrentFolderDates) { [weak self] response in
                            // 【疑問】 [weak self] は必要？
                            guard let self = self else { return }
                            switch response {
                            case .success():
                                self.tableView.beginUpdates()
                                self.tableView.reloadSections([indexPath.section], with: .automatic)
                                self.tableView.endUpdates()
                            case .failure(let error):
                                FuncUtility.showErrorDialog(error: error, title: "データの更新に失敗しました", currentVC: self)
                            }
                        }
                    }
                case .failure(let error):
                    FuncUtility.showErrorDialog(error: error, title: "データの更新に失敗しました", currentVC: self)
                }
            }
        })
        self.navigationController?.pushViewController(fileVC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "記録一覧",
                                                                style: .done,
                                                                target: nil,
                                                                action: nil)
    }

}

extension FolderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if folderSections[section].isShowed {
            let year = folderSections[section].year
            // 実際に使うときにアンラップしてnilじゃないかどうか確認してあげる
            if let currentFolderDates = currentFolderDateDictionary[year] {
                return currentFolderDates.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.identifier, for: indexPath) as? FolderTableViewCell else {
            fatalError("FolderTableViewCellが返ってきてません")
        }
        let year = folderSections[indexPath.section].year
        guard let currentFolderDates = currentFolderDateDictionary[year] else {
            return UITableViewCell()
        }
        folderCell.configure(folderDate: currentFolderDates[indexPath.row])
        return folderCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        folderSections.count
    }
}

extension FolderViewController: UIPickerViewDelegate {
}

extension FolderViewController: UIPickerViewDataSource {
    // UIPickerViewで必須
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        componentFiles.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        componentFiles[component].count
    }

    // UIPickerViewで任意
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        String(componentFiles[component][row]) // Stringに変更
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let yearSelected = self.yearArrayChoosed[pickerView.selectedRow(inComponent: 0)]
        let monthSelected = self.monthArray[pickerView.selectedRow(inComponent: 1)]

        changeErrorTextLabel(label: label, yearSelected: yearSelected, monthSelected: monthSelected)
    }
}
