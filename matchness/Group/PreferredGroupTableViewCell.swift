//
//  GroupTableViewCell.swift
//  matchness
//
//  Created by user on 2019/06/06.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

class PreferredGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupTestImage: UIImageView!
    @IBOutlet weak var titel: UILabel!//タイトル
    @IBOutlet weak var period: UILabel!//期間
    @IBOutlet weak var joinNumber: UILabel!//参加人数
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var groupFlag: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
