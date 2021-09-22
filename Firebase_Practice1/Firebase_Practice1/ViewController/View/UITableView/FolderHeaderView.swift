//
//  FolderHeaderView.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit

final class FolderHeaderView: UITableViewHeaderFooterView {

    static let identifier = "FolderHeaderView"
    static func nib() -> UINib {
        UINib(nibName: "FolderHeaderView", bundle: nil)
    }
    @IBOutlet private weak var folderHeaderDateLabel: UILabel!
    @IBOutlet private weak var accordionImageView: UIImageView!
    @IBOutlet private weak var totalDateLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        folderHeaderDateLabel.text = nil
        totalDateLabel.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ThemeColor.backgroundColor
    }

    // ViewはModelの中身を知らなくてもいい(Modelを保持しなくていい)
    // 外から値を貰えば処理を実行できる(外からprivateのプロパティに値を渡せる)
    func configure(folderSection: FolderSection) {
        folderHeaderDateLabel.text = String(folderSection.year)+"年"
        totalDateLabel.text = "合計 "+String(folderSection.totalDayInYear)+" 日"
        totalDateLabel.addAccent(pattern: String(folderSection.totalDayInYear), color: ThemeColor.mainColor) // 管理したい
    }

    // Viewにロジックを書いてしまっているけど、、
    // こんぐらいのロジックだったらいい？とりあえず保留
    func rotateImageView(folderSection: FolderSection) {
        // 【疑問】animationが働いていない
        UIView.animate(withDuration: 1) {
            // 初期値はtrueで下向きであるべき
            if folderSection.isShowed {
                self.accordionImageView.transform = CGAffineTransform(rotationAngle: .pi)
            } else {
                self.accordionImageView.transform = .identity
            }
        }
    }
}
