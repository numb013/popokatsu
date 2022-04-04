//
//  CalenderCell.swift
//  Calender
//
//  Created by 中村篤史 on 2021/10/23.
//  Copyright © 2021 中西康之. All rights reserved.
//

import UIKit

class CalenderCell: UICollectionViewCell {

    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var memoImage: UIImageView!
    @IBOutlet weak var graphview: UIView!
    @IBOutlet weak var graphview_2: UIView!
    @IBOutlet var dayEvents: [UILabel]!
    @IBOutlet weak var topLine: NSLayoutConstraint!
    @IBOutlet weak var topLine_2: NSLayoutConstraint!
    @IBOutlet weak var sideLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
