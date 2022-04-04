//
//  ChatImageCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/11/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseStorage

class ChatImageCell: UITableViewCell {
    let storage = Storage.storage()
    let host = "gs://popo-katsu-266622.appspot.com"
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var message: Message?
    var message_users: [String:String]? {
        didSet {
            if let message_users = message_users {
                let profileImageURL = image_url + message_users["target_imag"]!
                userImageView.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }
        }
    }

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerPostImageView: UIImageView!
    @IBOutlet weak var myPostImageView: UIImageView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var dayInterval: UILabel!
    @IBOutlet weak var dayIntervalView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        
        partnerPostImageView.layer.cornerRadius = 15
        myPostImageView.layer.cornerRadius = 15
        dayIntervalView.layer.cornerRadius = 9
        
        partnerPostImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,  .layerMaxXMaxYCorner]
        myPostImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "HH:mm"
        
        if message?.from == message_users!["user_id"] {
            partnerPostImageView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            myPostImageView.isHidden = false
            myDateLabel.isHidden = false

            if let message = message {
                let url = image_url + message.image_url!
                storage.reference(forURL: host).child("images/").child(message.image_url!)
                    .getData(maxSize: 3 * 1024 * 1024, completion: { data, error in
                        let imageData = data
                        let image = UIImage(data: imageData!)
                        DispatchQueue.main.async(execute: {
                            self.myPostImageView?.image = image
                        })
                    })
                myDateLabel.text = dateFormatter.string(from: StringToDate(dateValue: message.create_at, format: "yyyy-MM-dd HH:mm:ss"))
            }
        } else {
            partnerPostImageView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            myPostImageView.isHidden = true
            myDateLabel.isHidden = true

            if let message = message {
                storage.reference(forURL: host).child("images/").child(message.image_url!)
                    .getData(maxSize: 3 * 1024 * 1024, completion: { data, error in
                        let imageData = data
                        let image = UIImage(data: imageData!)
                        DispatchQueue.main.async(execute: {
                            self.partnerPostImageView?.image = image
                        })
                    })
                partnerDateLabel.text = dateFormatter.string(from: StringToDate(dateValue: message.create_at, format: "yyyy-MM-dd HH:mm:ss"))
            }
        }
    }
    
    func StringToDate(dateValue: String, format: String) -> Date {
       let dateFormatter = DateFormatter()
       dateFormatter.calendar = Calendar(identifier: .gregorian)
       dateFormatter.dateFormat = format
       return dateFormatter.date(from: dateValue) ?? Date()
   }
}
