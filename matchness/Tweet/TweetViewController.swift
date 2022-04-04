//  TweetViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//
import UIKit
import DZNEmptyDataSet
import Alamofire
import SwiftyJSON
import XLPagerTabStrip
import SDWebImage
//import Lottie

@available(iOS 13.0, *)
class TweetViewController: BaseViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UINavigationControllerDelegate {

    var itemInfo: IndicatorInfo = "すべて"
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    private var requestAlamofire: Alamofire.Request?;
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    let dateFormater = DateFormatter()
    var dataSource = [ApiTweetList]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var isUpdate = false
    var page_no = 1
    var tweet_id: Int = 0
    var is_like = 0
    var like_change_count = 0
    var requestUrl: String = "";
    var refreshControl:UIRefreshControl!
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        if let tabBarItem = self.tabBarController?.tabBar.items?[1] as? UITabBarItem {
            tabBarItem.badgeValue = nil
        }

        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        self.tableView.register(UINib(nibName: "TweetCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetCommentTableViewCell")

        apiRequest()
        self.navigationItem.title = "すべて"
        tableView.tableFooterView = UIView(frame: .zero)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.contentInset.bottom = 100
        tableView.addSubview(self.refreshControl)
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("タブバー表示")
        BaseViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "つぶやき"
        //タブバー非表示
        tabBarController?.tabBar.isHidden = false
        self.page_no = 1
        dataSource = []
        apiRequest()
    }

    @objc func refreshTable() {
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        self.page_no = 1

        dataSource = []
        apiRequest()
        self.refreshControl?.endRefreshing()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= tableView.contentSize.height - self.tableView.bounds.size.height)  && isUpdate == true {
            isUpdate = false
            self.page_no += 1
            apiRequest()
        }
    }

    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/

        let parameters = [
            "page" : self.page_no,
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectTweet, parameters: parameters,success: { [self] (response: [ApiTweetList]) in
            isUpdate = response.count < 5 ? false : true
            dataSource.append(contentsOf: response)
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "まだつぶやきはありません", attributes:stringAttributes)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
        
        if dataSource.count == 0 {
            return cell
        }
        var tweet = dataSource[indexPath.row]

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //GoogleAd
//        if (tweet?.name == "ad") {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "AdTableViewCell") as! AdTableViewCell
//            let baseView = cell.adSet
//
//            if UIScreen.main.nativeBounds.height >= 1792 {
//                self.add_height = add_height_1
//            } else {
//                self.add_height = add_height_2
//            }
//            sampleGoogleAdView = SampleGoogleAdView(
//                frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height:self.add_height)
//            )
//            baseView!.addSubview(sampleGoogleAdView) //baseViewに広告を追加
//            loadAd()
//            return cell
//        }

        if (tweet.type == 2) {
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
            cell.name.text = tweet.name

            cell.rename.layer.cornerRadius = 12
            cell.rename.clipsToBounds = true
            cell.rename.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
            cell.rename.text = "Re:" + tweet.target_name! + "   "
            cell.rename.numberOfLines = 0
            //最大値の設定。　幅固定で高さはいい感じにしたい、と言う場合はこのように高さの最大値を無限大に
            let maxSize = CGSize(width: self.view.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let size = cell.rename.sizeThatFits(maxSize)
            //後でcenterを設定するためCGPointのx、yはどんな値でもよき
            cell.rename.frame = CGRect(origin: CGPoint(x:0, y: 0), size: size)
            cell.rename.center = self.view.center
            
            cell.like_text_height.constant = 0
            cell.like_list_button.isHidden = true
            

            cell.like_count.text = String(tweet.like_count)
            if (tweet.profile_image == nil) {
                cell.profile_image.image = UIImage(named: "no_image")
            } else {
                let profileImageURL = image_url + (tweet.profile_image)
                cell.profile_image.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }

            cell.profile_image.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.targetUserId = tweet.user_id
            cell.profile_image.addGestureRecognizer(recognizer)

            cell.like_button.isEnabled = true
            cell.like_button.tag = indexPath.row
            cell.like_button.addTarget(self, action: "likePush:", for: .touchUpInside)

            cell.comment_button.tag = indexPath.row
            cell.comment_button.addTarget(self, action: "commentPush:", for: .touchUpInside)
            
            var image_comment = UIImage(named: "detail_comment")
            cell.comment_button.setImage(image_comment, for: .normal)
            
            cell.menu_button.tag = indexPath.row
            cell.menu_button.addTarget(self, action: "menuPush:", for: .touchUpInside)

            var image = UIImage(named: "tweet_like")
            if (tweet.is_like) >= 1 {
                image = UIImage(named: "tweet_liked")
            }
            let state = UIControl.State.normal
            cell.like_button.setImage(image, for: state)

            return cell
        }

        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = dateFormater.date(from: tweet.created_at as! String)
        cell.created_at?.text = date!.toFuzzy()

        cell.like_text_height.constant = 0
        cell.like_list_button.isHidden = true
        
        cell.message?.text = (tweet.message)
        cell.message?.adjustsFontSizeToFitWidth = true
        cell.message?.numberOfLines = 0
        cell.name.text = tweet.name
        cell.like_count.text = String(tweet.like_count)
        cell.comment_count.text = String(tweet.comment_count)

        cell.tag = indexPath.row
        if (tweet.profile_image == nil) {
            cell.profile_image.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (tweet.profile_image)
            cell.profile_image.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }

        cell.profile_image.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        recognizer.targetUserId = tweet.user_id
        cell.profile_image.addGestureRecognizer(recognizer)

        cell.like_button.isEnabled = true
        cell.like_button.tag = indexPath.row
        cell.like_button.addTarget(self, action: "likePush:", for: .touchUpInside)

        cell.comment_button.tag = indexPath.row
        cell.comment_button.addTarget(self, action: "commentPush:", for: .touchUpInside)

        cell.menu_button.tag = indexPath.row
        cell.menu_button.addTarget(self, action: "menuPush:", for: .touchUpInside)

        var image = UIImage(named: "tweet_like")
        if (tweet.is_like) >= 1 {
            image = UIImage(named: "tweet_liked")
        }
        let state = UIControl.State.normal
        cell.like_button.setImage(image, for: state)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.dataSource.count == 0 {
            return
        }
        var param = self.dataSource[indexPath.row]
        let detailTweet = TweetDetailViewController()
        detailTweet.tweet_id = (param.tweet_id)
        navigationController?.pushViewController(detailTweet, animated: true)

    }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200 //セルの高さ
        return UITableView.automaticDimension //自動設定
    }
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    @objc private func menuPush(_ sender:UIButton)
    {
        // UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var target_tweet = self.dataSource[sender.tag]

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
                self.deletePush((target_tweet.tweet_id))
            }
            alertController.addAction(actionNoChoise)
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
                    "target_id":String((target_tweet.user_id)),
                    "tweet_id":String((target_tweet.tweet_id)),
                    "type":2
                ]
                present(contactView, animated: true, completion: nil)
//                navigationController?.pushViewController(contactView, animated: true)
            } else {
                //ブロック
                userFavoriteBlock((target_tweet.user_id))
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
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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

    @objc private func likePush(_ sender:UIButton)
    {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        var target_tweet = self.dataSource[sender.tag]
        if target_tweet.type == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TweetTableViewCell
            cell.like_button.isEnabled = false
//            let like_tweet_id = target_tweet?.tweet_id
            self.is_like = (target_tweet.is_like)
            //リクエスト先
//            var requestUrl: String = "";
            if self.is_like == 1 {
                var image = UIImage(named: "tweet_like")
                cell.like_button.setImage(image, for: .normal)
                cell.like_count.text = String(target_tweet.like_count - 1)
                self.dataSource[sender.tag].like_count = target_tweet.like_count - 1
                self.like_change_count = target_tweet.like_count - 1
                self.dataSource[sender.tag].is_like = 0
                //リクエスト先
//                self.requestUrl = ApiConfig.REQUEST_URL_API_LIKE_CANCEL_TWEET;
            } else {
                var image = UIImage(named: "tweet_liked")
                cell.like_button.setImage(image, for: .normal)
                cell.like_count.text = String(target_tweet.like_count + 1)
                self.dataSource[sender.tag].like_count = target_tweet.like_count + 1
                self.like_change_count = target_tweet.like_count + 1
                self.dataSource[sender.tag].is_like = 1
                //リクエスト先
//                self.requestUrl = ApiConfig.REQUEST_URL_API_LIKE_TWEET;
            }
            cell.like_button.isEnabled = true
            

        } else {

            let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TweetCommentTableViewCell
            cell.like_button.isEnabled = false
            self.is_like = (target_tweet.is_like)
            //リクエスト先
            var requestUrl: String = "";
            if self.is_like >= 1 {
                var image = UIImage(named: "tweet_like")
                cell.like_button.setImage(image, for: .normal)
                cell.like_count.text = String(target_tweet.like_count - 1)
                self.dataSource[sender.tag].like_count = target_tweet.like_count - 1
                self.like_change_count = target_tweet.like_count - 1
                self.dataSource[sender.tag].is_like = 0
                //リクエスト先
                // self.requestUrl = ApiConfig.REQUEST_URL_API_LIKE_CANCEL_TWEET;
            } else {
                var image = UIImage(named: "tweet_liked")
                cell.like_button.setImage(image, for: .normal)
                cell.like_count.text = String(target_tweet.like_count + 1)
                self.dataSource[sender.tag].like_count = target_tweet.like_count + 1
                self.like_change_count = target_tweet.like_count + 1
                self.dataSource[sender.tag].is_like = 1
                // self.requestUrl = ApiConfig.REQUEST_URL_API_LIKE_TWEET;
            }
            cell.like_button.isEnabled = true
        }
        
        //リクエスト先
        var setAPIModule : APIModule = POPOAPI.base.likeTweet
        var parameters = [String:Any]()
        if target_tweet.type == 1 {
            parameters["tweet_id"] = target_tweet.tweet_id
            parameters["type"] = 1
            setAPIModule = POPOAPI.base.likeCancelTweet
        } else {
            parameters["type"] = 2
            parameters["tweet_comment_id"] = target_tweet.tweet_comment_id
            parameters["tweet_id"] = target_tweet.tweet_id
        }
        
        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
                self.dataSource[sender.tag].like_count = self.like_change_count - 1
                self.dataSource[sender.tag].is_like = 0
                
                if response.message == "2" {
                    let alertController:UIAlertController =
                        UIAlertController(title:"ポイントが不足しています",message: "いいねするにはポイント5p必要です", preferredStyle: .alert)
                    let backView = alertController.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
                    cancelAction.setValue(#colorLiteral(red: 0, green: 0.71307832, blue: 0.7217405438, alpha: 1), forKey: "titleTextColor")
                    defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
                    // actionを追加
                    alertController.addAction(cancelAction)
                    alertController.addAction(defaultAction)
                    // UIAlertControllerの起動
                    self.present(alertController, animated: true, completion: nil)

                }
//              cell.like_button.isEnabled = true
            } else {
//              cell.like_button.isEnabled = true
//                 if detailParam.is_like == 1 {
//                  print("いいねのアニメーションアニメーションアニメーションアニメーション")
//                  showAnimation()
//              }
            }
//          tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func requestAlamofireMethod(headers:HTTPHeaders, query:Dictionary<String,String>, sender:UIButton) {
        self.requestAlamofire = AF.request(self.requestUrl, method: .post, parameters: query, encoding: JSONEncoding.default, headers: headers).responseJSON{ [self] response in
            switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    guard let detailParam = try? JSONDecoder().decode(detailParam.self, from: data) else {
                        return
                    }
                    if detailParam.status == "NG" {
                        self.dataSource[sender.tag].like_count = self.like_change_count - 1
                        self.dataSource[sender.tag].is_like = 0
                        
                        if detailParam.message == "2" {
                            let alertController:UIAlertController =
                                UIAlertController(title:"ポイントが不足しています",message: "いいねするにはポイント5p必要です", preferredStyle: .alert)
                            let backView = alertController.view.subviews.last?.subviews.last
                            backView?.layer.cornerRadius = 15.0
                            backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
                            cancelAction.setValue(#colorLiteral(red: 0, green: 0.71307832, blue: 0.7217405438, alpha: 1), forKey: "titleTextColor")
                            defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
                            // actionを追加
                            alertController.addAction(cancelAction)
                            alertController.addAction(defaultAction)
                            // UIAlertControllerの起動
                            self.present(alertController, animated: true, completion: nil)

                        }
//                        cell.like_button.isEnabled = true
                    } else {
//                        cell.like_button.isEnabled = true
//                        if detailParam.is_like == 1 {
//                            print("いいねのアニメーションアニメーションアニメーションアニメーション")
//                            showAnimation()
//                        }
                    }
//                    tableView.reloadData()
            case .failure:
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        }
    }
    
    
    func deletePush(_ target_tweet_id:Int){
        let parameters = [
            "tweet_id" : target_tweet_id
        ] as! [String:Any]
        
        API.requestHttp(POPOAPI.base.deleteTweet, parameters: parameters,success: { [self] (response:ApiStatus) in
                var alert = UIAlertController(title: "削除", message: "つぶやきを削除しました", preferredStyle: .alert)
                let myString  = "削除しました"
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 20.0)])
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), range: NSRange(location:0,length:myString.count))
                alert.setValue(myMutableString, forKey: "attributedTitle")

                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                        self.apiRequest()
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
            },
            failure: { [self] error in
                print(error)
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
    @objc private func commentPush(_ sender:UIButton)
    {
        var target_tweet = self.dataSource[sender.tag]
        let vc = AddTweetCommentView()
        vc.tweet_id = (target_tweet.tweet_id)
        vc.name = (target_tweet.name)
        vc.target_user_id = (target_tweet.user_id)
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func goDeleteTweet(_ sender : Any) {
        let addTweet = AddTweetView()
        navigationController?.pushViewController(addTweet, animated: true)
    }
}
