//
//  SideMenuCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/10/07.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import SDWebImage

class SideMenuCell: UITableViewCell {
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    @IBOutlet weak var pointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.layer.cornerRadius = icon.frame.width / 2
        let imageText = userDefaults.object(forKey: "profile_image") as! String
        let profileImageURL = image_url + imageText
        icon.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        label.text = userDefaults.object(forKey: "user_name") as! String
        rankLabel.text = ApiConfig.RANK_NAME_LIST[userDefaults.object(forKey: "rank") as! Int ?? 0]
        var point = userDefaults.object(forKey: "point") as! Int
        pointLabel.text = String(point) + " pt"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
