//
//  CalenderTextCell.swift
//  Calender
//
//  Created by 中村篤史 on 2021/10/23.
//  Copyright © 2021 中西康之. All rights reserved.
//

import UIKit

class CalenderTextCell: UITableViewCell {
    
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
