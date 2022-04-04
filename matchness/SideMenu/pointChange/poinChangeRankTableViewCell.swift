//
//  poinChangeRankTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2020/08/06.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit

class poinChangeRankTableViewCell: UITableViewCell {

    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var name_text: UILabel!
    @IBOutlet weak var prefecter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
