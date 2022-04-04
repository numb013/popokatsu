//
//  NewGroupPepleTopTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/04/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

class NewGroupPepleTopTableViewCell: UITableViewCell {

    @IBOutlet weak var topStep: UILabel!
    @IBOutlet weak var kikan: UILabel!
    @IBOutlet weak var peple: UILabel!
    @IBOutlet weak var ranking: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
