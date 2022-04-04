//
//  PointChangeCellTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2020/07/06.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit

class PointChangeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var userPoint: UILabel!
    @IBOutlet weak var todayStep: UILabel!
    @IBOutlet weak var yesterdayStep: UILabel!
    @IBOutlet weak var todayPoint: UILabel!
    @IBOutlet weak var yesterdayPoint: UILabel!
    @IBOutlet weak var t_button: UIButton!
    @IBOutlet weak var y_button: UIButton!
    @IBOutlet weak var payButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
