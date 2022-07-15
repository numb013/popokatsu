//
//  MenuTableViewCell.swift
//  accordion-menu-sample
//
//  Created by 櫻井寛海 on 2018/07/25.
//  Copyright © 2018 Hiromi Sakurai. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    var tappedHandler: (() -> Void)?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    @objc private func toggleCheckBox() {
        guard let handler = tappedHandler else { return }
        handler()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- view settings
extension MenuTableViewCell {
    func setupViews() {
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
//        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.93).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
        
//        contentView.addSubview(checkBoxButton)
//        checkBoxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
//        checkBoxButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        checkBoxButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
//        checkBoxButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true

    }
}
