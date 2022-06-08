//
//  RouletteViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2022/04/26.
//  Copyright © 2022 a2c. All rights reserved.
//

import UIKit

class RouletteViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var headView1: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
