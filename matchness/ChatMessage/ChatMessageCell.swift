//
//  ChatMessageCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/11/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ChatMessageCell: UITableViewCell {

    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var dayInterval: UILabel!
    @IBOutlet weak var dayIntervalView: UIView!
    
    var message: Message? {
        didSet {
            if let message = message {
                partnerMessageTextView.text = message.text
            }
        }
    }
    
    var message_users: [String:String]? {
        didSet {
            if let message_users = message_users {
                let profileImageURL = image_url + message_users["target_imag"]!
                userImageView.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        dayIntervalView.layer.cornerRadius = 9
        userImageView.layer.cornerRadius = userImageView.frame.width / 2

        partnerMessageTextView.layer.cornerRadius = 15
        partnerMessageTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,  .layerMaxXMaxYCorner]
        partnerMessageTextView.textContainerInset = UIEdgeInsets(top: 15, left: 5, bottom: 5, right: 5)
        partnerMessageTextView.sizeToFit()
        
        myMessageTextView.textContainerInset = UIEdgeInsets(top: 15, left: 5, bottom: 5, right: 5)
        myMessageTextView.sizeToFit()
        myMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
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
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false

            if let message = message {
                myMessageTextView.text = message.text
                myDateLabel.text = dateFormatter.string(from: StringToDate(dateValue: message.create_at, format: "yyyy-MM-dd HH:mm:ss"))
            }
        } else {
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true

            if let message = message {
                partnerMessageTextView.text = message.text
                partnerDateLabel.text = dateFormatter.string(from: StringToDate(dateValue: message.create_at, format: "yyyy-MM-dd HH:mm:ss"))
            }
        }
        
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func StringToDate(dateValue: String, format: String) -> Date {
       let dateFormatter = DateFormatter()
       dateFormatter.calendar = Calendar(identifier: .gregorian)
       dateFormatter.dateFormat = format
       return dateFormatter.date(from: dateValue) ?? Date()
   }
}
