//
//  FileTableViewCell.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit

//final class FileTableViewCell: UITableViewCell {
//    
//    static let identifier = "FileTableViewCell"
//    static func nib() -> UINib {
//        UINib(nibName: "FileTableViewCell", bundle: nil)
//    }
//    
//    @IBOutlet private weak var fileImageView: UIImageView!
//    @IBOutlet private weak var fileDateLabel: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        backgroundColor = ThemeColor.cellBackgroundColor
//        accessoryType = .disclosureIndicator
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        fileDateLabel.text = nil
//    }
//
//    func configure(fileDate: FileDate) {
//        fileDateLabel.text = String(fileDate.month)+"/"+String(fileDate.day)+" (\(fileDate.week))"
//    }
//    
//}
