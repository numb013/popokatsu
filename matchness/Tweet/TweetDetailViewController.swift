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
import DZNEmptyDataSet
import SDWebImage
//import Lottie

@available(iOS 13.0, *)
class TweetDetailViewController: UIViewController, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDataSource, tweetDetailDelegate, tweetCommentDelegate {
    
    @IBOutlet var tableView: UITableView!
    private var requestAlamofire: Alamofire.Request?;
    let dateFormater = DateFormatter()
    var dataSource = [ApiTweetDetail]()
    var dataComment = [ApiTweetComment]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var isUpdate = false
    var page_no = 1
    var tweet_id: Int = 0
    var is_like = 0
    var requestUrl: String = "";
    var refreshControl:UIRefreshControl!
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        tableView.contentInset.bottom = 100
        tableView.tableFooterView = UIView()
        
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        navigationController!.navigationBar.topItem!.title = ""
        navigationController?.setNavigationBarHidden(false, animated: false)

        self.tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        self.tableView.register(UINib(nibName: "TweetCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetCommentTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "詳細"
        tabBarController?.tabBar.isHidden = true
        pageReset()
    }

    @objc func refreshTable() {
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        pageReset()
        self.refreshControl?.endRefreshing()
    }
    
    func pageReset() {
        self.page_no = 1
        dataSource = []
        dataComment = []
        apiRequest()
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (!self.isUpdate) {
//            if (!self.isLoading && scrollView.contentOffset.y  >= tableView.contentSize.height - self.tableView.bounds.size.height) {
//                self.isLoading = true
//                apiRequest()
//            }
//        }
//    }

    func apiRequest() {
        let parameters = [
            "tweet_id": tweet_id
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectTweetDetail, parameters: parameters,success: { [self] (response: [ApiTweetDetail]) in
            dataSource = response
            isUpdate = dataSource[0].tweet_comment.count < 5 ? false : true
            dataComment.append(contentsOf: dataSource[0].tweet_comment)
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "つぶやきはありません", attributes:stringAttributes)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataComment.count != 0 {
            return dataComment.count + 1
        } else if dataSource.count == 1 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
            cell.selectionStyle = .none
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.tweetDetail = dataSource[0]
            return cell
        }
    
        var index = indexPath.row-1
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCommentTableViewCell") as! TweetCommentTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        cell.tweetComment = dataComment[index]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            return
        }
        var param = self.dataComment[indexPath.row-1]
        if param.tweet_comment_id != nil {
            let detailTweet = TweetCommentDetailViewController()
            detailTweet.tweet_id = (param.tweet_id)!
            detailTweet.tweet_comment_id = (param.tweet_comment_id)!
            navigationController?.pushViewController(detailTweet, animated: true)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200 //セルの高さ
        return UITableView.automaticDimension //自動設定
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
//
//    @objc private func likeListPush(_ sender:UIButton)
//    {
//        var target_tweet = self.dataSource[sender.tag]
//        let tweetLikeListView = TweetLikeListViewController()
//        tweetLikeListView.tweet_id = (target_tweet.tweet_id)!
//        tweetLikeListView.type = "1"
//        navigationController?.pushViewController(tweetLikeListView, animated: true)
//    }
    
    @objc private func commentLikePush(_ sender:UIButton)
    {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag+1, section: 0)) as! TweetCommentTableViewCell
        cell.like_button.isEnabled = false
        var target_tweet = self.dataComment[sender.tag]
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        if target_tweet.is_like! >= 1 {
            setAPIModule = POPOAPI.base.likeCancelTweet
        }

        let parameters = [
            "type": 2,
            "tweet_comment_id":target_tweet.tweet_comment_id,
            "tweet_id":target_tweet.tweet_id
        ] as! [String:Any]
        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
//                    self.dataSource[sender.tag]?.like_count = self.like_change_count - 1
//                    self.dataSource[sender.tag]?.is_like = 0

            } else {
//                    if detailParam.is_like == 1 {
//                        showAnimation()
//                    }
            }
            pageReset()
            },
            failure: { [self] error in
                print(error)
                return;
            }
        )

    }
    
    @objc private func likePush(_ sender:UIButton)
    {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        var target_tweet = self.dataSource[sender.tag]
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        if target_tweet.is_like! >= 1 {
            setAPIModule = POPOAPI.base.likeCancelTweet
        }

        let parameters = [
            "type": 1,
            "tweet_id":target_tweet.tweet_id
        ] as! [String:Any]

        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
//                    self.dataSource[sender.tag]?.like_count = self.like_change_count - 1
//                    self.dataSource[sender.tag]?.is_like = 0

            } else {
//                    if detailParam.is_like == 1 {
//                        showAnimation()
//                    }
            }
            pageReset()
            },
            failure: { [self] error in
                print(error)
                return;
            }
        )
    }

//    func showAnimation() {
//        let animationView = AnimationView(name: "like-animation")
//        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
//        animationView.center = self.view.center
////        animationView.loopMode = .loop
//        animationView.contentMode = .scaleAspectFit
//        animationView.animationSpeed = 1
//
//        view.addSubview(animationView)
//
//        animationView.play { finished in
//            if finished {
//                animationView.removeFromSuperview()
//            }
//        }
//    }
    
    func report(_ type:Int, _ user_id:Int, _ tweet_id:Int){
        if #available(iOS 13.0, *) {
            if type == 1 {
                //通報
                let contactView = ContactViewController()
                contactView.type = 2
                contactView.report_param = [
                    "target_id":String(user_id),
                    "tweet_id":String(tweet_id),
                    "type":2
                ]
                present(contactView, animated: true, completion: nil)
//                navigationController?.pushViewController(contactView, animated: true)
            } else {
                //ブロック
                userFavoriteBlock(user_id)
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
        
        API.requestHttp(POPOAPI.base.createFavoriteBlock, parameters: parameters,success: { [self] (response: ApiStatus) in
                var alert_title = "ブロックしました"
                var alert_text = "ユーザーをブロックしました"
                let alert = UIAlertController(title: alert_title, message: alert_text, preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
                var alert = UIAlertController(title: "削除", message: "つぶやきを削除しました", preferredStyle: .alert)
                let myString  = "削除しました"
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 20.0)])
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), range: NSRange(location:0,length:myString.count))
                alert.setValue(myMutableString, forKey: "attributedTitle")

                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                        pageReset()
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
                backView?.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )
    }
    
    @objc func goAddTweet(_ sender : Any) {
        let addTweet = AddTweetView()
        navigationController?.pushViewController(addTweet, animated: true)
    }
    
    @objc func goDeleteTweet(_ sender : Any) {
        let addTweet = AddTweetView()
        navigationController?.pushViewController(addTweet, animated: true)
    }
    
    
    func userTap(_ user_id:Int) {
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeTap(_ tweet_id: Int, _ setAPIModule: APIModule) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        let parameters = [
            "type": 1,
            "tweet_id":tweet_id
        ] as! [String:Any]

        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
            } else {
            }
            pageReset()
            },
            failure: { [self] error in
                print(error)
                return;
            }
        )
    }
    
    func commentTap(_ tweet_id:Int, _ name:String, _ user_id:Int) {
        let vc = AddTweetCommentView()
        vc.tweet_id = tweet_id
        vc.name = name
        vc.target_user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }

    func commentLikeTap(_ tweet_id: Int, _ tweet_comment_id: Int, _ setAPIModule: APIModule) {
        let parameters = [
            "type": 2,
            "tweet_comment_id":tweet_comment_id,
            "tweet_id":tweet_id
        ] as! [String:Any]
        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: detailParam) in
            pageReset()
            },
            failure: { [self] error in
                print(error)
                return;
            }
        )
    }
    
    func likeListTap(_ tweet_id: Int) {
        let tweetLikeListView = TweetLikeListViewController()
        tweetLikeListView.tweet_id = tweet_id
        tweetLikeListView.type = "1"
        navigationController?.pushViewController(tweetLikeListView, animated: true)
    }
    
    func menuTap(_ tweet_id: Int?, _ tweet_comment_id:Int?, _ my_tweet_comment:Int?, _ my_tweet:Int?, _ user_id:Int) {
        // UIAlertController
       let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if tweet_comment_id == nil {//親つぶやき
            if my_tweet != 1 {
                let actionChoise1 = UIAlertAction(title: "つぶやきを通報", style: .default){
                    action in
                    self.report(1, user_id, tweet_id!)
                }
                alertController.addAction(actionChoise1)

                let actionChoise2 = UIAlertAction(title: "ユーザーをブロックする", style: .default){
                    action in
                    self.report(2, user_id, tweet_id!)
                }
                alertController.addAction(actionChoise2)
            }
            if my_tweet == 1 {
                let actionNoChoise = UIAlertAction(title: "削除する", style: .destructive){
                action in
                    self.deletePush(tag: (tweet_id)!, Tweet_type:1)
                }
                alertController.addAction(actionNoChoise)
            }

        } else {//コメントつぶやき
            if my_tweet_comment != 1 {
                let actionChoise1 = UIAlertAction(title: "つぶやきを通報", style: .default){
                    action in
                    self.report(1, user_id, tweet_id!)
                }
                alertController.addAction(actionChoise1)

                let actionChoise2 = UIAlertAction(title: "ユーザーをブロックする", style: .default){
                    action in
                    self.report(2, user_id, tweet_id!)
                }
                alertController.addAction(actionChoise2)
            }
            if my_tweet_comment == 1 {
                let actionNoChoise = UIAlertAction(title: "削除する", style: .destructive){
                action in
                    self.deletePush(tag: (tweet_comment_id)!, Tweet_type:2)
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
}
