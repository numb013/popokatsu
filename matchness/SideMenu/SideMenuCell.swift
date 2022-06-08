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
        if let imageText = userDefaults.object(forKey: "profile_image") as? String {
            let profileImageURL = image_url + imageText
            icon.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }
        if let userName = userDefaults.object(forKey: "user_name") as? String {
            label.text = userName
        }
        if let rank = userDefaults.object(forKey: "rank") as? Int {
            rankLabel.text = ApiConfig.RANK_NAME_LIST[rank]
        } else {
            rankLabel.text = ApiConfig.RANK_NAME_LIST[0]
        }

        if let point = userDefaults.object(forKey: "point") as? Int {
            pointLabel.text = String(point) + " pt"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
