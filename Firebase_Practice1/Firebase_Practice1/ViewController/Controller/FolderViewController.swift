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

    private let folderSectionRepository = FolderSectionRepositroy()
    private let folderDateRepository = FolderDateRepository()

    private var folderSectionDocumentReferenceId: String?

    private var yearArrayChoosed: [Int] = []
    private let monthArray = TimeArray.monthArray
    private var componentFiles: [[Int]] = []


    private var folderSections: [FolderSection] = []
//    private var folderDates: [FolderDate] = [] // Firebaseでorderでソートしてyearが一致しているものを取ってこれるようなstatic関数を作っておく
    private var currentFolderDateDictionary: [Int: [FolderDate]] = [:]
//    private var folderDates: [FolderSection: [FolderDate]] = [:] // こっちに帰れるなら変えたい

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 【実験】File画面から戻ったときにこれが毎回呼ばれるかどうか
        // 【結果】呼ばれる！ // 先にtotalDayInYearSectionがクロージャで変わっていない笑
        showCurrentFolderSections()
        showCurrentFolderDates()
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
    // 【課題】completionを自作したい
    func showCurrentFolderSections() {
        folderSectionRepository.fetchFolderSection { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let folderSections):
                self.folderSections = folderSections
                self.tableView.reloadData()
            case .failure(let error):
                FuncUtility.showErrorDialog(error: error, title: "データの読み込みに失敗しました", currentVC: self)
            }
        }

        
//        FolderSection.showFolderSectionsForFirestore(completionAction: { (querySnapshot, error) in
//            if let error = error {
//                FuncUtility.showErrorDialog(error: error,
//                                            title: "FolderSectionの取得失敗",
//                                            currentVC: self)
//                return
//            }
//            guard let querySnapshot = querySnapshot else { return }
//
//            // これで本来やりたかったことのスコープがシンプルになる
//            // 実際にこれなんやからずにmapでいい けど structやcodble、unique？にしないと駄目？
//            var folderSectionArray: [FolderSection] = []
//
//            for doc in querySnapshot.documents {
//                let folderSection = FolderSection(doc: doc)
//                folderSectionArray.append(folderSection)
//            }
//            self.folderSections = folderSectionArray
//
//
//            guard let reloadHander = completion else { return }
//            reloadHander()
//
//
////            self.tableView.reloadData() // tableViewとは本来メソッドの責務を超える気がする
//        })
    }

    func showCurrentFolderDates() {
        folderDateRepository.fetchFolderDate { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let folderDateDictionary):
                self.currentFolderDateDictionary = folderDateDictionary
                self.tableView.reloadData()
            case .failure(let error):
                FuncUtility.showErrorDialog(error: error, title: "データの読み込みに失敗しました", currentVC: self)
            }
            
        }


//        FolderDate.showFolderDateForFirestore(completionAction: { (querySnapshot, error) in
//            // 例外処理
//            if let error = error {
//                // エラーではしっかりとアラートを出して終わり
//                FuncUtility.showErrorDialog(error: error,
//                                            title: "FolderDateの取得失敗",
//                                            currentVC: self)
//                return
//            }
//            guard let querySnapshot = querySnapshot else {
//                return
//            }
//
//            // 本来やらせたいこと
//            var folderDateDictionay: [Int: [FolderDate]] = [:]
//            // whereField,イコールyear と order.monthをしてインデックスを作るべき？ // セキュリティもやる
//            for doc in querySnapshot.documents {
//                print("doc:", doc) // for文の回数を見る
//                let folderDate = FolderDate(doc: doc)
//                let year = folderDate.year
//                if folderDateDictionay[year] == nil {
//                    folderDateDictionay[year] = [] // yearに対応したものだけが入る // classなのになぜDBに保存されているからデータが共有化されていないのか？
//                }
//                folderDateDictionay[year]?.append(folderDate)
//            }
//            print("querySnapshot.documents.count: ", querySnapshot.documents.count)
//            print("folderDateDictionary.count: ", folderDateDictionay.count) // いくつの年数が入っているか
//            self.currentFolderDateDictionary = folderDateDictionay
//            print("self.currentFolderDates: ", self.currentFolderDateDictionary)
//
//            guard let reloadHander = completion else { return }
//            reloadHander()
//
////            self.tableView.reloadData() // 2回目はめんどくさいけど今の所しょうがない
//        })
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
        // 【疑問】ここの1を導くのがmonthだととても大変そう
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
                                        // Voidに変更になったのでlet documentReferenceを削除
                                        case .success():
                                            self.currentFolderDateDictionary[year] = []
                                            // 【疑問】これだとどうやって合わせればいいのか、多分無理なので、プロパティidとしてdocumentIdを持たしたい！！
//                                            self.folderSectionDocumentReferenceId = documentReference.documentID
                                            // FolderDateでもtableView.reload()をするので省略しても遅延の体感時間は誤差
                                            // でも、結局最新のFolderSectionはとってこないといけない
                                            self.showCurrentFolderSections()
                                        case .failure(let error):
                                            FuncUtility.showErrorDialog(error: error, title: "データの追加に失敗しました", currentVC: self)
                                        }
                                    }


//                                    FolderSection.createFolderSectionToFirestore(year: year,
//                                                                                 completionAction: { error in
//                                        if let error = error {
//                                            FuncUtility.showErrorDialog(error: error,
//                                                                        title: "FolderSectionの作成失敗",
//                                                                        currentVC: self)
//                                        } else {
//                                            print("FolderSectionの作成成功")
//                                            // 【変更後】
//                                            self.currentFolderDateDictionary[year] = [] // 新しく作られるときにその年をnilじゃなく[]にする
//                                            self.showCurrentFolderSections(completion: { [weak self] in
//                                                self?.tableView.reloadData()
//                                            }) // これいるのかな、、、tableview.reload２回やっている
//                                        }
//                                    })
                                    // 【変更前】
//                                    self.currentFolderDateDictionary[year] = [] // 新しく作られるときにその年をnilじゃなく[]にする
//                                    self.showCurrentFolderSections()
                                }

                                if !isCommonInMonth {
                                    // 【パターン②】
                                    let newFolderDate = FolderDate(year: year, month: month)
                                    self.folderDateRepository.addFolderDate(folderDate: newFolderDate) { [weak self] response in
                                        guard let self = self else { return }
                                        switch response {
                                        // Voidに変更になったのでlet documentReferenceを削除
                                        case .success():
                                            self.showCurrentFolderDates()
                                        case .failure(let error):
                                            FuncUtility.showErrorDialog(error: error, title: "データの追加に失敗しました", currentVC: self)
                                        }
                                    }
                                    // 【パターン①】
//                                    FolderDate.createFolderDateToFirestore(year: year, month: month, completionAction: { error in
//                                        if let error = error {
//                                            FuncUtility.showErrorDialog(error: error,
//                                                                        title: "FolderDateの作成失敗",
//                                                                        currentVC: self)
//                                        } else {
//                                            print("FolderDateの作成成功")
//                                            self.showCurrentFolderDates(completion: { [weak self] in
//                                                self?.tableView.reloadData()
//                                            })
//                                        }
//                                    })
                                    // 【変更前】
//                                    self.showCurrentFolderDates()
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
        guard let section = sender.view?.tag else {
            return
        }
        // folderSectionのプロパティにidを入れたので削除
//        guard let documentReferenceId = folderSectionDocumentReferenceId else {
//            return
//        }
        // 【パターン①】documentIdをVCで管理する場合
        folderSections[section].isShowed.toggle()
        // isShowedの変更をFirestoreに更新する
        folderSectionRepository.toggleIsShowed(folderSection: folderSections[section]) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success():
                self.tableView.beginUpdates()
                // isShowedの変更後に表示する
                self.tableView.reloadSections([section], with: .fade)
                self.tableView.endUpdates()
            case .failure(let error):
                FuncUtility.showErrorDialog(error: error, title: "データの更新に失敗しました", currentVC: self)
            }
        }
        // 【パターン②】documentIdをそのままプロパティとして管理する場合
//        FolderSection.isShowedUpdate(folderSection: folderSections[section],
//                                     completionAction: { error in
//                                        if let error = error {
//                                            FuncUtility.showErrorDialog(error: error,
//                                                                        title: "FolderSection更新失敗",
//                                                                        currentVC: self)
//                                        } else {
//                                            print("FolderSection更新成功")
//                                            // 【変更後】// これでスムーズにできる？　// そもそもtableのリロードでなぜ、isShowedが更新されているのか
//                                            // 【曖昧】より細かく見ないとわからないが結果的にfolderSection[section]のisShowedが変わっている
//                                            // 【疑問】PCはネットに繋いでいないのにDBと接続できている？
//                                            self.tableView.beginUpdates()
//                                            self.tableView.reloadSections([section], with: .fade)
//                                            self.tableView.endUpdates()
//                                        }
//                                     })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 【保留】
//        guard let currentFolderDates = currentFolderDateDictionary[folderSections[indexPath.section].year] else {
//            return
//        }
//        let fileVC = FileViewController.instantiate(folderDate: currentFolderDates[indexPath.row], addFile: { [weak self] in
//            guard let strongSelf = self else { return }
//            // 【DB変更後】
//            FolderDate.updateTotalDayInMonth(folderDate: currentFolderDates[indexPath.row],
//                                             fileDatesCount: $0,
//                                             completionAction: { error in
//                                                if let error = error {
//                                                    FuncUtility.showErrorDialog(error: error,
//                                                                                title: "folderDateTotalDayの計算失敗",
//                                                                                currentVC: strongSelf)
//                                                } else {
//                                                    print("folderDateTotalDayの計算成功")
//                                                    // totalDayInMonthが終わったらInYearで計算する
//                                                    // 【課題】ネストが深くなって見にくいので何かいい方法ない？ // 引数書かないといけないのが犠牲になる？
//                                                    // 【問題】昔のままのfolderDatesを渡してしまっている！！！！！！！！！！！！！
//                                                    // 【解決】currnetFolderDates → nextCurrentFolderDates
//                                                    strongSelf.showCurrentFolderDates(completion: nil) // 最新のものに更新
//                                                    guard let nextCurrentFolderDate = strongSelf.currentFolderDateDictionary[strongSelf.folderSections[indexPath.section].year] else {
//                                                        return
//                                                    }
//                                                    // 【保留パターン②】
//                                                    strongSelf.folderSectionRepository.calculateTotalDayInYear
//                                                    // 【保留パターン①】
////                                                    FolderSection.calculateTotalDayInYearSection(folderSection: strongSelf.folderSections[indexPath.section], folderDates: nextCurrentFolderDate, completionAction: { error in
////                                                        if let error = error {
////                                                            FuncUtility.showErrorDialog(error: error,
////                                                                                        title: "folderSectionTotalDayの計算失敗",
////                                                                                        currentVC: strongSelf)
////                                                        } else {
////                                                            print("folderSectionTotalDayの計算成功")
////
////                                                            // 最新のFolderSectionとして表示させる
////                                                            strongSelf.tableView.beginUpdates()
////                                                            strongSelf.tableView.reloadSections([indexPath.section], with: .automatic)
////                                                            strongSelf.tableView.endUpdates()
////                                                            //                                                                strongSelf.showCurrentFolderSections() // これより上の書き方が良い
////                                                        }
////                                                    })
//                                                }
//                                             })
//        })
//        self.navigationController?.pushViewController(fileVC, animated: true)
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "記録一覧",
//                                                                style: .done,
//                                                                target: nil,
//                                                                action: nil)
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
