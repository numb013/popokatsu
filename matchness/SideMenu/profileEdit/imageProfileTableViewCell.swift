//
//  imageProfileTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2020/04/09.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit

class imageProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var image_1: UIImageView!
    @IBOutlet weak var image_2: UIImageView!
    @IBOutlet weak var image_3: UIImageView!
    @IBOutlet weak var image_4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
