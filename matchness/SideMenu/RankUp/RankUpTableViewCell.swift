//
//  RankUpTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2020/04/15.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit

class RankUpTableViewCell: UITableViewCell {

    @IBOutlet weak var setMonth: UILabel!
    
    @IBOutlet weak var period: UILabel!
    
    @IBOutlet weak var monthStep: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
