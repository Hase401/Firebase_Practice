//
//  UILabel+Accent.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit

extension UILabel {

    /// 対象の文字列に対して、アクセント色を付加する
    ///
    /// - Parameters:
    ///   - pattern: 対象の文字列
    ///   - color: アクセント色
    func addAccent(pattern: String, color: UIColor) {
        // String
        let strings = [attributedText?.string, text].compactMap { $0 }
        guard let string = strings.first else { return }

        // Ranges
        let nsRanges = string.nsRanges(of: pattern, options: [.literal])
        if nsRanges.count == 0 { return }

        // Add Color
        let attributedString = attributedText != nil
            ? NSMutableAttributedString(attributedString: attributedText!)
            : NSMutableAttributedString(string: string)

        for nsRange in nsRanges {
            attributedString.addAttributes([.foregroundColor: color], range: nsRange)
        }

        // Set
        attributedText = attributedString
    }

}
