//
//  FolderTableViewCell.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit

final class FolderTableViewCell: UITableViewCell {

    static let identifier = "FolderTableViewCell"
    static func nib() -> UINib {
        UINib(nibName: "FolderTableViewCell", bundle: nil)
    }

    @IBOutlet private weak var folderImageView: UIImageView!
    @IBOutlet private weak var folderDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = ThemeColor.cellBackgroundColor
        accessoryType = .disclosureIndicator
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        folderDateLabel.text = nil
    }

    func configure(folderDate: FolderDate) {
        folderDateLabel.text = String(folderDate.year)+"年"+String(folderDate.month)+"月"
    }
    
}
