//
//  TweetDetailViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/01/20.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie
import SDWebImage

@available(iOS 13.0, *)
class TweetCommentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var requestAlamofire: Alamofire.Request?;
    let dateFormater = DateFormatter()
    var dataSource = [ApiTweetComment]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var isUpdate = false
    var page_no = 1
    var is_like = 0
    var tweet_comment_id = Int()
    var tweet_id = Int()
    var requestUrl: String = "";
    var refreshControl:UIRefreshControl!
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        navigationController!.navigationBar.topItem!.title = ""
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tableView.register(UINib(nibName: "TweetCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetCommentTableViewCell")
        
        apiRequest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "コメント詳細"
        tabBarController?.tabBar.isHidden = true
    }


    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "tweet_comment_id": tweet_comment_id,
            "tweet_id": tweet_id
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.detailTweetComment, parameters: parameters,success: { [self] (response: [ApiTweetComment]) in
                dataSource = response
                if dataSource.count == 0 {
                    navigationController?.popViewController(animated: true)
                } else {
                    tableView.reloadData()
                }

            },
            failure: { [self] error in
                print(error)
            }
        )

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tweet = self.dataSource[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCommentTableViewCell") as! TweetCommentTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = dateFormater.date(from: tweet.created_at as! String)
        cell.created_at?.text = date!.toFuzzy()

        cell.message?.text = tweet.message
        cell.tag = indexPath.row
        
        cell.message?.adjustsFontSizeToFitWidth = true
        cell.message?.numberOfLines = 0
        cell.name.text = tweet.name!

        cell.rename.layer.cornerRadius = 12
        cell.rename.clipsToBounds = true
        cell.rename.backgroundColor = .popoTextGreen
        cell.rename.text = "Re:" + tweet.target_name! + "  "
        cell.rename.numberOfLines = 0
        //最大値の設定。　幅固定で高さはいい感じにしたい、と言う場合はこのように高さの最大値を無限大に
        let maxSize = CGSize(width: self.view.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let size = cell.rename.sizeThatFits(maxSize)
        //後でcenterを設定するためCGPointのx、yはどんな値でもよき
        cell.rename.frame = CGRect(origin: CGPoint(x:0, y: 0), size: size)
        cell.rename.center = self.view.center

        cell.like_count.text = String(tweet.like_count!)
        if (tweet.profile_image == nil) {
            cell.profile_image.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (tweet.profile_image!)
            cell.profile_image.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }
        
        cell.like_button.isEnabled = true
        cell.like_button.tag = indexPath.row
        cell.like_button.addTarget(self, action: "likePush:", for: .touchUpInside)

        if tweet.like_count == 0 {
            cell.like_text_height.constant = 0
            cell.like_list_button.isHidden = true
        } else {
            cell.like_list_button.isHidden = false
            cell.like_text_height.constant = 40
            cell.like_list_button.tag = indexPath.row
            cell.like_list_button.setTitle("     " + String(tweet.like_count!) + "人がいいね！しています", for:UIControl.State.normal)
            cell.like_list_button.addTarget(self, action: "likeListPush:", for: .touchUpInside)
        }
        
        cell.comment_button.tag = indexPath.row
        cell.comment_button.addTarget(self, action: "commentPush:", for: .touchUpInside)

        cell.menu_button.tag = indexPath.row
        cell.menu_button.addTarget(self, action: "menuPush:", for: .touchUpInside)

        var image = UIImage(named: "tweet_like")
        if (tweet.is_like)! >= 1 {
            image = UIImage(named: "tweet_liked")
        }
        let state = UIControl.State.normal
        cell.like_button.setImage(image, for: state)

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200 //セルの高さ
        return UITableView.automaticDimension //自動設定
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    @objc private func likeListPush(_ sender:UIButton)
    {
        // 日付のフォーマット
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH時mm分"

        var target_tweet = self.dataSource[sender.tag]
        let tweetLikeListView = TweetLikeListViewController()
        tweetLikeListView.tweet_id = (target_tweet.tweet_id)!
        tweetLikeListView.type = "2"
        navigationController?.pushViewController(tweetLikeListView, animated: true)
    }
    

    @objc private func likePush(_ sender:UIButton)
    {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TweetCommentTableViewCell
        cell.like_button.isEnabled = false
        var target_tweet = self.dataSource[sender.tag]
        let like_tweet_id = target_tweet.tweet_id
        self.is_like = (target_tweet.is_like)!


        
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        if self.is_like >= 1 {
            setAPIModule = POPOAPI.base.likeCancelTweet
        }
        var parameters = [String:Any]()
        if target_tweet.type == 1 {
            parameters["type"] = "1"
        } else {
            parameters["type"] = "2"
            parameters["tweet_comment_id"] = String((target_tweet.tweet_comment_id!))
        }
        parameters["tweet_id"] = like_tweet_id
        
        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
//                    self.dataSource[sender.tag]?.like_count = self.like_change_count - 1
//                    self.dataSource[sender.tag]?.is_like = 0
                if response.message == "2" {
                    let alertController:UIAlertController =
                        UIAlertController(title:"ポイントが不足しています",message: "いいねするにはポイント5p必要です", preferredStyle: .alert)
                    let backView = alertController.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = .white
                    // Default のaction
                    let defaultAction:UIAlertAction =
                        UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
                            (action:UIAlertAction!) -> Void in
                            let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        })

                    // Cancel のaction
                    let cancelAction:UIAlertAction =
                        UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                            (action:UIAlertAction!) -> Void in
                            // 処理
                            print("キャンセル")
                        })
                    cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
                    defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
                    // actionを追加
                    alertController.addAction(cancelAction)
                    alertController.addAction(defaultAction)
                    // UIAlertControllerの起動
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
//                    if detailParam.is_like == 1 {
//                        showAnimation()
//                    }
            }
            self.apiRequest()
            },
            failure: { [self] error in
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )
    }

    @objc private func menuPush(_ sender:UIButton)
    {
        // UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var target_tweet = self.dataSource[sender.tag]

        if target_tweet.tweet_comment_id == nil {//親つぶやき
            if target_tweet.my_tweet != 1 {
                let actionChoise1 = UIAlertAction(title: "つぶやきを通報", style: .default){
                    action in
                    self.report(1, tag: sender.tag)
                }
                alertController.addAction(actionChoise1)

                let actionChoise2 = UIAlertAction(title: "ユーザーをブロックする", style: .default){
                    action in
                    self.report(2, tag: sender.tag)
                }
                alertController.addAction(actionChoise2)
            }
            if target_tweet.my_tweet == 1 {
                let actionNoChoise = UIAlertAction(title: "削除する", style: .destructive){
                action in
                    self.deletePush(tag: (target_tweet.tweet_id)!, Tweet_type:1)
                }
                alertController.addAction(actionNoChoise)
            }

        } else {//コメントつぶやき
            if target_tweet.my_tweet_comment != 1 {
                let actionChoise1 = UIAlertAction(title: "つぶやきを通報", style: .default){
                    action in
                    self.report(1, tag: sender.tag)
                }
                alertController.addAction(actionChoise1)

                let actionChoise2 = UIAlertAction(title: "ユーザーをブロックする", style: .default){
                    action in
                    self.report(2, tag: sender.tag)
                }
                alertController.addAction(actionChoise2)
            }
            if target_tweet.my_tweet_comment == 1 {
                let actionNoChoise = UIAlertAction(title: "削除する", style: .destructive){
                action in
                    self.deletePush(tag: (target_tweet.tweet_comment_id)!, Tweet_type: 2 )
                }
                alertController.addAction(actionNoChoise)
            }

        }
        
        let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel){
            (action) -> Void in
            print("Cancel")
            }

       alertController.addAction(actionCancel)
       // UIAlertControllerの起動
        self.present(alertController, animated: true, completion: nil)
    }

    func report(_ type:Int, tag:Int){
        var target_tweet = self.dataSource[tag]
        if #available(iOS 13.0, *) {
            if type == 1 {
                //通報
                let contactView = ContactViewController()
                contactView.type = 2
                contactView.report_param = [
                    "target_id":String((target_tweet.user_id!)),
                    "tweet_id":String((target_tweet.tweet_id!)),
                    "type":2
                ]
                present(contactView, animated: true, completion: nil)
//                navigationController?.pushViewController(contactView, animated: true)
            } else {
                //ブロック
                userFavoriteBlock((target_tweet.user_id)!)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func userFavoriteBlock(_ user_id:Int){

        let parameters = [
            "target_id" : user_id,
            "status" : 2
        ] as! [String:Any]
        
        API.requestHttp(POPOAPI.base.createFavoriteBlock, parameters: parameters,success: { [self] (response: ApiFavoriteBlock) in
                var alert_title = "ブロックしました"
                var alert_text = "ユーザーをブロックしました"
                let alert = UIAlertController(title: alert_title, message: alert_text, preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = .white
                // アラート表示
                self.present(alert, animated: true, completion: {
                    // アラートを閉じる
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.apiRequest()
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func deletePush(tag:Int, Tweet_type:Int){
        //リクエスト先
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        var parameters = [String:Any]()
        if Tweet_type == 1 {
            parameters["type"] = 1
            parameters["tweet_id"] = tag
            setAPIModule = POPOAPI.base.deleteTweet
        } else {
            parameters["type"] = 2
            parameters["tweet_comment_id"] = tag
            setAPIModule = POPOAPI.base.deleteTweetComment
        }

        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: ApiStatus) in
                var alert = UIAlertController(title: "削除", message: "削除しました", preferredStyle: .alert)
                var myString = "つぶやきを削除しました"
                if Tweet_type == 2 {
                    myString = "コメントを削除しました"
                }
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 20.0)])
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.popoTextPink, range: NSRange(location:0,length:myString.count))
                alert.setValue(myMutableString, forKey: "attributedTitle")

                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                        self.apiRequest()
                        alert.dismiss(animated: true, completion: nil)
                    })
                })

            },
            failure: { [self] error in
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = .white
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )

//        //パラメーターdelete_tweet_comment
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        var requestUrl :String = ""
//        if Tweet_type == 1 {
//            //リクエスト先
//            requestUrl = ApiConfig.REQUEST_URL_API_DELETE_TWEET;
//            query["type"] = "1"
//            query["tweet_id"] = String(tag)
//        } else {
//            //リクエスト先
//            requestUrl = ApiConfig.REQUEST_URL_API_DELETE_TWEET_COMMENT
//            query["type"] = "2"
//            query["tweet_comment_id"] = String(tag)
//        }
//
//        var headers: HTTPHeaders = [:]
//        var api_key = userDefaults.object(forKey: "api_token") as? String
//        if ((api_key) != nil) {
//            headers = [
//                "Accept" : "application/json",
//                "Authorization" : "Bearer " + api_key!,
//                "Content-Type" : "application/x-www-form-urlencoded"
//            ]
//        }
//        self.requestAlamofire = AF.request(requestUrl, method: .post, parameters: query, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
//            switch response.result {
//            case .success:
//                var alert = UIAlertController(title: "削除", message: "削除しました", preferredStyle: .alert)
//                var myString = "つぶやきを削除しました"
//                if Tweet_type == 2 {
//                    myString = "コメントを削除しました"
//                }
//                var myMutableString = NSMutableAttributedString()
//                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 20.0)])
//                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), range: NSRange(location:0,length:myString.count))
//                alert.setValue(myMutableString, forKey: "attributedTitle")
//
//                self.present(alert, animated: true, completion: {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
//                        self.apiRequest()
//                        alert.dismiss(animated: true, completion: nil)
//                    })
//                })
//
//            case .failure:
//                //  リクエスト失敗 or キャンセル時
//                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
//                let backView = alert.view.subviews.last?.subviews.last
//                backView?.layer.cornerRadius = 15.0
//                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                self.present(alert, animated: true, completion: {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
//                        alert.dismiss(animated: true, completion: nil)
//                    })
//                })
//                return;
//            }
//        }
    }


    @objc func goAddTweet(_ sender : Any) {
        let addTweet = AddTweetView()
        navigationController?.pushViewController(addTweet, animated: true)
    }
    
    @objc private func commentPush(_ sender:UIButton)
    {
        var target_tweet = self.dataSource[sender.tag]
        let vc = AddTweetCommentView()
        vc.tweet_id = (target_tweet.tweet_id!)
        vc.name = (target_tweet.name!)
        vc.target_user_id = (target_tweet.user_id!)
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func goDeleteTweet(_ sender : Any) {
        let addTweet = AddTweetView()
        navigationController?.pushViewController(addTweet, animated: true)
    }
}
