//
//  MyButton.swift
//  Firebase_Practice1
//
//  Created by 長谷川孝太 on 2021/09/13.
//

import UIKit

final class MyButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeColor.mainColor
        tintColor = UIColor.white
        layer.cornerRadius = 25

        dropButtonShadow()
    }

    // FABSecondaryButtonと違ってViewをlayerの前につけなくていい
    private func dropButtonShadow() {
        layer.shadowColor = ThemeColor.shadowColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 25.0
    }
}
