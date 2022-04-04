//
//  NewGroupPepleTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/04/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

class NewGroupPepleTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lastLoginTime: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var userStep: UILabel!
    @IBOutlet weak var step: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.height / 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
