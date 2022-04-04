//
//  AdTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/02/12.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

class AdTableViewCell: UITableViewCell {

    
    @IBOutlet weak var adSet: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
