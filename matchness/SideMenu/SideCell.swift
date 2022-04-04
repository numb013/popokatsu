//
//  SideCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/12/11.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

class SideCell: UICollectionViewCell {

    @IBOutlet weak var badge: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        badge.layer.cornerRadius = badge.frame.width / 2
        badge.clipsToBounds = true// この設定を入れないと角丸にならない
        // Initialization code
    }

}
