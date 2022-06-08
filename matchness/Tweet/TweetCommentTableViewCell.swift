//
//  TweetTableViewCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/01/20.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

protocol tweetCommentDelegate {
    func userTap(_ user_id:Int)
    func commentLikeTap(_ tweet_id: Int,_ tweet_comment_id:Int , _ setAPIModule: APIModule)
    func menuTap(_ tweet_id: Int?, _ tweet_comment_id:Int?, _ my_tweet_comment:Int?, _ my_tweet:Int?, _ user_id:Int)
    func commentTap(_ tweet_id:Int, _ name:String, _ user_id:Int)
}

class TweetCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var like_count: UILabel!
    @IBOutlet weak var created_at: UILabel!
    @IBOutlet weak var rename: UILabel!
    @IBOutlet weak var comment_button: UIButton!
    @IBOutlet weak var like_button: UIButton!
    @IBOutlet weak var menu_button: UIButton!
    @IBOutlet weak var like_list_button: UIButton!
    @IBOutlet weak var like_text_height: NSLayoutConstraint!
    
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    public var delegate: tweetCommentDelegate?

    weak var tweetComment: ApiTweetComment! {
        didSet {
            var tweet = tweetComment
            let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let date = dateFormater.date(from: tweet!.created_at as! String)
            created_at?.text = date!.toFuzzy()

            message?.text = tweet!.message
//            cell.tag = indexPath.row
            
            message?.adjustsFontSizeToFitWidth = true
            message?.numberOfLines = 0
            name.text = tweet!.name!

            rename.layer.cornerRadius = 12
            rename.clipsToBounds = true
            rename.backgroundColor = .popoTextGreen
            rename.text = "Re:" + tweet!.target_name! + "   "
            rename.numberOfLines = 0
            //最大値の設定。　幅固定で高さはいい感じにしたい、と言う場合はこのように高さの最大値を無限大に
//            let maxSize = CGSize(width: self.view.frame.width, height: CGFloat.greatestFiniteMagnitude)
//            let size = rename.sizeThatFits(maxSize)
            //後でcenterを設定するためCGPointのx、yはどんな値でもよき
//            rename.frame = CGRect(origin: CGPoint(x:0, y: 0), size: size)
//            rename.center = self.view.center
            
            like_text_height.constant = 0
            like_list_button.isHidden = true
            
            like_count.text = String(tweet!.like_count!)
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
//            like_button.tag = index
            like_button.addTarget(self, action: "commentLikePush:", for: .touchUpInside)

//            comment_button.tag = indexPath.row
            comment_button.addTarget(self, action: "commentPush:", for: .touchUpInside)
            
            var image_comment = UIImage(named: "detail_comment")
            comment_button.setImage(image_comment, for: .normal)
            
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
        // Initialization code
        profile_image.layer.cornerRadius = profile_image.frame.width / 2
    }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        delegate!.userTap(tweetComment.user_id!)
    }

    @objc private func commentLikePush(_ sender:UIButton)
    {
        like_button.isEnabled = false
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        if tweetComment.is_like! >= 1 {
            setAPIModule = POPOAPI.base.likeCancelTweet
        }
        delegate!.commentLikeTap(tweetComment.tweet_id!, tweetComment.tweet_comment_id!, setAPIModule)

    }
    
    @objc private func commentPush(_ sender:UIButton)
    {
        delegate!.commentTap(
            tweetComment.tweet_id!,
            tweetComment.name!,
            tweetComment.user_id!
        )
    }

    @objc private func menuPush(_ sender:UIButton)
    {
        delegate!.menuTap(
            tweetComment.tweet_id,
            tweetComment.tweet_comment_id,
            tweetComment.my_tweet_comment,
            tweetComment.my_tweet,
            tweetComment.user_id!
        )
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
