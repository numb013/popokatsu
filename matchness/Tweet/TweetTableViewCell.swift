//
//  TweetTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/01/20.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit


protocol tweetDetailDelegate {
    func userTap(_ user_id:Int)
    func likeTap(_ tweet_id: Int, _ setAPIModule: APIModule)
    func menuTap(_ tweet_id: Int?, _ tweet_comment_id:Int?, _ my_tweet_comment:Int?, _ my_tweet:Int?, _ user_id:Int)
    func commentTap(_ tweet_id:Int, _ name:String, _ user_id:Int)
    func likeListTap(_ tweet_id:Int)
}

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var like_count: UILabel!
    @IBOutlet weak var comment_count: UILabel!
    @IBOutlet weak var created_at: UILabel!
    @IBOutlet weak var comment_button: UIButton!
    @IBOutlet weak var like_button: UIButton!
    @IBOutlet weak var menu_button: UIButton!
    @IBOutlet weak var like_list_button: UIButton!
    @IBOutlet weak var like_text_height: NSLayoutConstraint!
    
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    public var delegate: tweetDetailDelegate?
    
    weak var tweetDetail: ApiTweetDetail! {
        didSet {

            var tweet = tweetDetail

            let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let date = dateFormater.date(from: tweet!.created_at as! String)
            created_at?.text = date!.toFuzzy()
            message?.text = tweet!.message
//            tag = indexPath.row
            message?.adjustsFontSizeToFitWidth = true
            message?.numberOfLines = 0
            name.text = tweet!.name!
            like_count.text = String(tweet!.like_count!)
            
            if tweet!.like_count == 0 {
                like_text_height.constant = 0
                like_list_button.isHidden = true
            } else {
                like_list_button.isHidden = false
                like_text_height.constant = 40
//                like_list_button.tag = indexPath.row
                like_list_button.setTitle("     " + String(tweet!.like_count!) + "人がいいね！しています", for:UIControl.State.normal)
                like_list_button.addTarget(self, action: "likeListPush:", for: .touchUpInside)
            }

            comment_count.text = String(tweet!.comment_count!)
            if (tweet!.profile_image == nil) {
                profile_image.image = UIImage(named: "no_image")
            } else {
                let profileImageURL = image_url + (tweet!.profile_image!)
                profile_image.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }

            profile_image.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.targetUserId = tweet!.user_id
            profile_image.addGestureRecognizer(recognizer)

            like_button.isEnabled = true
//            like_button.tag = indexPath.row
            like_button.addTarget(self, action: "likePush:", for: .touchUpInside)

//            comment_button.tag = indexPath.row
            comment_button.addTarget(self, action: "commentPush:", for: .touchUpInside)

//            menu_button.tag = indexPath.row
            menu_button.addTarget(self, action: "menuPush:", for: .touchUpInside)

            var image = UIImage(named: "tweet_like")
            if (tweet!.is_like)! >= 1 {
                image = UIImage(named: "tweet_liked")
            }
            let state = UIControl.State.normal
            like_button.setImage(image, for: state)

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile_image.layer.cornerRadius = profile_image.frame.width / 2
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        delegate!.userTap(tweetDetail.user_id!)
    }

    @objc private func likePush(_ sender:UIButton)
    {
        like_button.isEnabled = false
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        if tweetDetail.is_like! >= 1 {
            setAPIModule = POPOAPI.base.likeCancelTweet
        }
        
        delegate!.likeTap(tweetDetail.tweet_id!, setAPIModule)
    }
    
    @objc private func commentPush(_ sender:UIButton)
    {
        delegate!.commentTap(
            tweetDetail.tweet_id!,
            tweetDetail.name!,
            tweetDetail.user_id!
        )
    }

    @objc private func menuPush(_ sender:UIButton)
    {
        delegate!.menuTap(
            tweetDetail.tweet_id,
            tweetDetail.tweet_comment_id,
            tweetDetail.my_tweet_comment,
            tweetDetail.my_tweet,
            tweetDetail.user_id!
        )
    }
    @objc private func likeListPush(_ sender:UIButton)
    {
        delegate!.likeListTap(tweetDetail.tweet_id!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
