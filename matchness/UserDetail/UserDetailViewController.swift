//
//  UserDetailViewController.swift
//  matchness
//
//  Created by user on 2019/02/05.
//  Copyright © 2019年 a2c. All rights reserved.
//

import UIKit
import ImageViewer
import Alamofire
import SwiftyJSON
import SDWebImage
import Lottie

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var indexRow : Int?
    var targetString: String?
    var targetGroupId: Int?
    var targetUserId: Int?
    var amount: String?
    var pay_point_id: Int?
    var payment_id: String?
}

struct detailParam: Codable {
    let status: String?
    let message: String?
    let is_like: Int?
    let is_matche: Int?
}

class UserDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,GalleryItemsDataSource, UIViewControllerTransitioningDelegate {

    let userDefaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var LikeRequest: UIButton!
    @IBOutlet weak var gradationView: GradationView!
    private var requestAlamofire: Alamofire.Request?;
    var activityIndicatorView = UIActivityIndicatorView()
    var favorite_block_status = Int()
    var galleyItem: GalleryItem!
    var user_id:Int = 0
    var target_id:Int = 0

    var dataSource = [ApiUserDetailDate]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var ReportButton: UIBarButtonItem!
    var profile_text = ""
    var my_view = 0
    var is_matche = 0
    var profile_image = ""
    
    struct DataItem {
        let imageView: UIImage
        let galleryItem: GalleryItem
    }

    var items: [DataItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.navigationItem.title = "プロフィール"
        self.tableView?.register(UINib(nibName: "UserDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailTableViewCell")
        self.tableView?.register(UINib(nibName: "UserDetailInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailInfoTableViewCell")
        navigationController!.navigationBar.topItem!.title = ""

        LikeRequest.isHidden = true
        chatButton.isHidden = true

        LikeRequest.layer.cornerRadius = 5.0
        chatButton.layer.cornerRadius = 5.0

        tabBarController?.tabBar.isHidden = true
        ReportButton = UIBarButtonItem(title: "･･･", style: .done, target: self, action: #selector(ReportTap(_:)))
        self.navigationItem.rightBarButtonItems = [ReportButton]

        requestApi()
    }

    func requestApi() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            // 非同期処理などを実行
            Thread.sleep(forTimeInterval: 5)
            // 非同期処理などが終了したらメインスレッドでアニメーション終了
            DispatchQueue.main.async {
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
            }
        }
        
        
        
        let parameters = [
            "target_id": user_id
        ] as [String:Any]
        API.requestHttp(POPOAPI.base.userDetail, parameters: parameters,success: { [self] (response: [ApiUserDetailDate]) in
                dataSource = response
                self.activityIndicatorView.stopAnimating()
                tableView?.reloadData()
            },
            failure: { [self] error in
                print(error)
                // self.errorData = model.errorData;
                // Alert.common(alertNum: self.errorData, viewController: self)
            }
        )
        
        //リクエスト実行
//        if( !requestUserDetailModel.requestApi(url: requestUrl, addQuery: query) ){
//
//        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            // 非同期処理などを実行
            Thread.sleep(forTimeInterval: 5)
            // 非同期処理などが終了したらメインスレッドでアニメーション終了
            DispatchQueue.main.async {
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
            }
        }
        
        // ナビゲーションを透明にする処理
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 透明にしたナビゲーションを元に戻す処理
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController!.navigationBar.shadowImage = nil
        tabBarController?.tabBar.isHidden = true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if dataSource.isEmpty == false {
            return 3
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty == false {
            if section == 2 {
                return 9
            }
            return 1
        }
        return 0
    }
    
    // Sectioのタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionLabel:String? = nil
        if section == 1 {
            sectionLabel = "自己紹介"
        } else if section == 2 {
            sectionLabel = "プロフィール"
        }
        return sectionLabel
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detail = self.dataSource[0]
        if (detail != nil) {
            if (self.dataSource[0].favorite_block_status == nil) {
                self.favorite_block_status = 99
            } else {
                self.favorite_block_status = detail.favorite_block_status ?? 99
            }
        }

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailTableViewCell") as! UserDetailTableViewCell

            self.target_id = detail.id ?? 0
            if detail != nil {
                if detail.mypage_view == 0 {
                    if detail.is_like == 1 && detail.is_matche == 0 {
                        LikeRequest.isHidden = false
                        LikeRequest.isEnabled = false
                        LikeRequest.backgroundColor =  #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
                        LikeRequest.backgroundColor =  #colorLiteral(red: 0.4803626537, green: 0.05874101073, blue: 0.1950398982, alpha: 1)
                        LikeRequest.setTitle("いいね済み", for: .normal)
                    } else if detail.is_matche != 0 {
                        chatButton.isHidden = false
                    } else {
                        LikeRequest.isHidden = false
                    }
                } else {
                    self.my_view = 1
                    LikeRequest.isHidden = true
                    chatButton.isHidden = true
                }
            }

            if (detail != nil) {
                cell.rank_imag.isHidden = true
                if (detail.rank != 0) {
                    cell.rank_imag.isHidden = false
                    if (detail.rank == 1) {
                        cell.rank_imag.image = UIImage(named: "bronze")
                    }
                    if (detail.rank == 2) {
                        cell.rank_imag.image = UIImage(named: "silver")
                    }
                    if (detail.rank == 3) {
                        cell.rank_imag.image = UIImage(named: "gold")
                    }
                }

                if (detail.profile_image[0].id == nil) {
                    cell.UserMainImage.image = UIImage(named: "no_image")
                } else {
                    let profileImageURL = image_url + detail.profile_image[0].path!

                    self.profile_image = profileImageURL
                    let url = NSURL(string: profileImageURL);
                    let imageData = NSData(contentsOf: url! as URL) //もし、画像が存在しない可能性がある場合は、ifで存在チェック
                    var image0 = UIImage(data:imageData! as Data)
                    galleyItem = GalleryItem.image{ $0(image0) }
                    cell.UserMainImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                    cell.UserMainImage.isUserInteractionEnabled = true
                    var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                    recognizer.targetString = "1"
                    cell.UserMainImage.addGestureRecognizer(recognizer)
                    items.append(DataItem(imageView: image0!, galleryItem: galleyItem))
                }

                if (detail.profile_image[1].id == nil) {
                    cell.UserSubImage1.isHidden = true
                } else {
                    let profileImageURL = image_url + detail.profile_image[1].path!
                    let url = NSURL(string: profileImageURL);
                    let imageData = NSData(contentsOf: url! as URL) //もし、画像が存在しない可能性がある場合は、ifで存在チェック
                    var image1 = UIImage(data:imageData! as Data)
                    galleyItem = GalleryItem.image{ $0(image1) }
                    cell.UserSubImage1.image = image1
                    cell.UserSubImage1.isUserInteractionEnabled = true

                    var recognizer1 = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                    recognizer1.targetString = "2"
                    cell.UserSubImage1.addGestureRecognizer(recognizer1)
                    items.append(DataItem(imageView: image1!, galleryItem: galleyItem))
                }

                if (detail.profile_image[2].id == nil) {
                    cell.UserSubImage2.isHidden = true
                } else {
                    let profileImageURL = image_url + detail.profile_image[2].path!
                    let url = NSURL(string: profileImageURL);
                    let imageData = NSData(contentsOf: url! as URL) //もし、画像が存在しない可能性がある場合は、ifで存在チェック
                    var image2 = UIImage(data:imageData! as Data)
                    galleyItem = GalleryItem.image{ $0(image2) }
                    cell.UserSubImage2.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                    cell.UserSubImage2.isUserInteractionEnabled = true
                    var recognizer2 = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                    recognizer2.targetString = "3"
                    cell.UserSubImage2.addGestureRecognizer(recognizer2)
                    items.append(DataItem(imageView: image2!, galleryItem: galleyItem))
                }

                if (detail.profile_image[3].id == nil) {
                    cell.UserSubImage3.isHidden = true
                } else {
                    let profileImageURL = image_url + detail.profile_image[3].path!
                    let url = NSURL(string: profileImageURL);
                    let imageData = NSData(contentsOf: url! as URL) //もし、画像が存在しない可能性がある場合は、ifで存在チェック
                    var image3 = UIImage(data:imageData! as Data)
                    galleyItem = GalleryItem.image{ $0(image3) }
                    cell.UserSubImage3.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                    cell.UserSubImage3.isUserInteractionEnabled = true
                    var recognizer3 = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                    recognizer3.targetString = "4"
                    cell.UserSubImage3.addGestureRecognizer(recognizer3)
                    items.append(DataItem(imageView: image3!, galleryItem: galleyItem))
                }

                if (detail.profile_image[4].id == nil) {
                    cell.UserSubImage4.isHidden = true
                } else {
                    let profileImageURL = image_url + detail.profile_image[4].path!
                    let url = NSURL(string: profileImageURL);
                    let imageData = NSData(contentsOf: url! as URL) //もし、画像が存在しない可能性がある場合は、ifで存在チェック
                    var image4 = UIImage(data:imageData! as Data)
                    galleyItem = GalleryItem.image{ $0(image4) }
                    cell.UserSubImage4.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                    cell.UserSubImage4.isUserInteractionEnabled = true
                    var recognizer4 = MyTapGestureRecognizer(target: self,action: #selector(self.onTap(_:)))
                    recognizer4.targetString = "5"
                    cell.UserSubImage4.addGestureRecognizer(recognizer4)
                    items.append(DataItem(imageView: image4!, galleryItem: galleyItem))
                }
            }

            // いいねボタン設定
//            var target:Int = detail?.id ?? 0
//            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onLike(_:)))
//            recognizer.targetString = String(target)
//            cell.LikeButton.addGestureRecognizer(recognizer)

            return cell
        }
                
        if indexPath.section == 1 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "userDetailInfo")
            cell.textLabel!.numberOfLines = 0
            cell.backgroundColor =  UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if detail != nil {
                if (detail.profile_text == "") {
                    cell.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
                    self.profile_text = "自己紹介の入力はありません。"
                    cell.textLabel!.textColor = #colorLiteral(red: 0.572501719, green: 0.5725748539, blue: 0.5724850297, alpha: 1)
                } else {
                    cell.textLabel!.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    self.profile_text = detail.profile_text!
                }
            }

//            cell.textLabel!.font = UIFont.systemFont(ofSize: 12.0)
            cell.textLabel!.text = self.profile_text
            return cell
        }

        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailInfoTableViewCell") as! UserDetailInfoTableViewCell
            if indexPath.row == 0 {
                cell.title?.text = "ニックネーム"
                cell.detail?.adjustsFontSizeToFitWidth = true
                cell.detail?.numberOfLines = 0

                cell.detail?.text = detail.name
                return cell
            }

            if indexPath.row == 1 {
                cell.title?.text = "性別"
                cell.detail?.text = ApiConfig.SEX_LIST[detail.sex ?? 0]
                return cell
            }
            if indexPath.row == 2 {
                cell.title?.text = "年齢"
                cell.detail?.text = String(detail.age ?? 0) + "歳"
                return cell
            }
            
            if indexPath.row == 3 {
                cell.title?.text = "痩せたい箇所"
                cell.detail?.text = ApiConfig.FITNESS_LIST[detail.fitness_parts_id ?? 0]
                return cell
            }
            if indexPath.row == 4 {
                cell.title?.text = "血液型"
                cell.detail?.text = ApiConfig.BLOOD_LIST[detail.blood_type ?? 2]
                return cell
            }
            if indexPath.row == 5 {
                cell.title?.text = "職業"
                cell.detail?.text = ApiConfig.WORK_LIST[detail.work ?? 0]
                return cell
            }
            if indexPath.row == 6 {
                cell.title?.text = "居住地"
                
                cell.detail?.text = ApiConfig.PREFECTURE_LIST[detail.prefecture_id ?? 0]
                return cell
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailInfo")
        return cell!
    }

        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            tableView.estimatedRowHeight = 200 //セルの高さ
            return UITableView.automaticDimension //自動設定
        }
        if indexPath.section == 2 {
            return 55
        }
        tableView.estimatedRowHeight = 200 //セルの高さ
        return UITableView.automaticDimension //自動設定
     }

    func itemCount() -> Int {
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var number = sender.targetString!
        var nStr1:Int = Int(number)!
        var nStr = (nStr1 - Int(1))
        let galleryViewController = GalleryViewController(startIndex: nStr, itemsDataSource: self, configuration: [.deleteButtonMode(.none), .seeAllCloseButtonMode(.none), .thumbnailsButtonMode(.none)])
        self.present(galleryViewController, animated: true, completion: nil)
    }


    @IBAction func chatButton(_ sender: Any) {
        let message_users:[String:String] = [
            "room_code":(self.dataSource[0].room_code!),
            "user_id":String(self.dataSource[0].my_id!),
            "user_name":self.dataSource[0].my_name!,
            "point":String(self.dataSource[0].my_point!),
            "sex":String(self.dataSource[0].my_sex!),
            "my_image":self.dataSource[0].my_profile_image!,
            "target_imag":self.dataSource[0].target_imag!,
            "target_name":self.dataSource[0].name!,
        ]

        let vc = UIStoryboard(name: "ChatMessage", bundle: nil).instantiateInitialViewController()! as! ChatMessageViewController
        vc.message_users = message_users

        navigationController?.pushViewController(vc, animated: true)
    }


    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    @IBAction func addLikeButton(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        LikeRequest.isEnabled = false
        LikeRequest.backgroundColor =  #colorLiteral(red: 0.4790476561, green: 0.06026431173, blue: 0.1930198967, alpha: 1)
        LikeRequest.setTitle("いいね済み", for: .normal)

        let parameters = [
            "target_id" : user_id
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.createLike, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status != "NG" {
                showAnimation()
                if  response.is_matche != 0  {
                    self.is_matche = 1
                    self.chatButton.isHidden = false
                    self.LikeRequest.isHidden = true
                    var alert = UIAlertController(title: "マッチングしました", message: "メッセージが送れようになりました", preferredStyle: .alert)
                    let myString  = "マッチングしました"
                    var myMutableString = NSMutableAttributedString()
                    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 20.0)])
                    myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), range: NSRange(location:0,length:myString.count))
                    alert.setValue(myMutableString, forKey: "attributedTitle")
                    self.present(alert, animated: true, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                            self.requestApi()
                            alert.dismiss(animated: true, completion: nil)
                        })
                    })
                }
            } else {
                self.LikeRequest.isEnabled = true
                self.LikeRequest.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
                self.LikeRequest.setTitle("いいね", for: .normal)
                if response.message == "4" {
                    let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                    let backView = alert.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.present(alert, animated: true, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                            alert.dismiss(animated: true, completion: nil)
                        })
                    })
                } else if response.message == "8" {

                    let alert = UIAlertController(title: "アカウントが無効です", message: "申し訳ございませんが、ご利用停止にさせていただいています", preferredStyle: .alert)
                    let backView = alert.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.present(alert, animated: true, completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                            alert.dismiss(animated: true, completion: nil)
                        })
                    })
                } else if response.message == "2" {

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
                    cancelAction.setValue(#colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), forKey: "titleTextColor")
                    defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
                    // actionを追加
                    alertController.addAction(cancelAction)
                    alertController.addAction(defaultAction)
                    // UIAlertControllerの起動
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            },
            failure: { [self] error in
                print(error)
            }
        )
        
        
        
//        self.target_id = self.dataSource[0].id
//        //リクエスト先
//        let requestUrl: String = ApiConfig.REQUEST_URL_API_ADD_LIKE;
//        //パラメーター
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        query["target_id"] = "\(user_id)"
//        var headers: HTTPHeaders = [:]
//        var api_key = userDefaults.object(forKey: "api_token") as? String
//        if ((api_key) != nil) {
//            headers = [
//                "Accept" : "application/json",
//                "Authorization" : "Bearer " + api_key!,
//                "Content-Type" : "application/x-www-form-urlencoded"
//            ]
//        }
        
//        self.requestAlamofire = AF.request(requestUrl, method: .post, parameters: query, encoding: JSONEncoding.default, headers: headers).responseJSON{ [self] response in
//            switch response.result {
//            case .success:
//                guard let data = response.data else { return }
//                guard let detailParam = try? JSONDecoder().decode(detailParam.self, from: data) else {
//                    return
//                }
//                if detailParam.status != "NG" {
//
//                    showAnimation()
//
//                    if  detailParam.is_matche != 0  {
//                        self.is_matche = 1
//                        self.chatButton.isHidden = false
//                        self.LikeRequest.isHidden = true
//                        var alert = UIAlertController(title: "マッチングしました", message: "メッセージが送れようになりました", preferredStyle: .alert)
//                        let myString  = "マッチングしました"
//                        var myMutableString = NSMutableAttributedString()
//                        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 20.0)])
//                        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), range: NSRange(location:0,length:myString.count))
//                        alert.setValue(myMutableString, forKey: "attributedTitle")
//                        self.present(alert, animated: true, completion: {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
//                                self.requestApi()
//                                alert.dismiss(animated: true, completion: nil)
//                            })
//                        })
//                    }
//
//                } else {
//
//                    self.LikeRequest.isEnabled = true
//                    self.LikeRequest.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
//                    self.LikeRequest.setTitle("いいね", for: .normal)
//
//                    if detailParam.message == "4" {
//                        let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
//                        let backView = alert.view.subviews.last?.subviews.last
//                        backView?.layer.cornerRadius = 15.0
//                        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        self.present(alert, animated: true, completion: {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
//                                alert.dismiss(animated: true, completion: nil)
//                            })
//                        })
//                    } else if detailParam.message == "8" {
//
//                        let alert = UIAlertController(title: "アカウントが無効です", message: "申し訳ございませんが、ご利用停止にさせていただいています", preferredStyle: .alert)
//                        let backView = alert.view.subviews.last?.subviews.last
//                        backView?.layer.cornerRadius = 15.0
//                        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        self.present(alert, animated: true, completion: {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
//                                alert.dismiss(animated: true, completion: nil)
//                            })
//                        })
//                    } else if detailParam.message == "2" {
//
//                        let alertController:UIAlertController =
//                            UIAlertController(title:"ポイントが不足しています",message: "いいねするにはポイント5p必要です", preferredStyle: .alert)
//                        let backView = alertController.view.subviews.last?.subviews.last
//                        backView?.layer.cornerRadius = 15.0
//                        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                        // Default のaction
//                        let defaultAction:UIAlertAction =
//                            UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
//                                (action:UIAlertAction!) -> Void in
//                                let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
//                                self.navigationController?.pushViewController(vc, animated: true)
//                            })
//
//                        // Cancel のaction
//                        let cancelAction:UIAlertAction =
//                            UIAlertAction(title: "キャンセル",style: .cancel,handler:{
//                                (action:UIAlertAction!) -> Void in
//                                // 処理
//                                print("キャンセル")
//                            })
//                        cancelAction.setValue(#colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), forKey: "titleTextColor")
//                        defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
//                        // actionを追加
//                        alertController.addAction(cancelAction)
//                        alertController.addAction(defaultAction)
//                        // UIAlertControllerの起動
//                        self.present(alertController, animated: true, completion: nil)
//                    }
//                }
//            case .failure:
//                self.LikeRequest.isEnabled = true
//                self.LikeRequest.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
//                self.LikeRequest.setTitle("いいね", for: .normal)
//
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
    
    func showAnimation() {
        let animationView = AnimationView(name: "love")
        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        animationView.center = self.view.center
//        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 2

        view.addSubview(animationView)

        animationView.play { finished in
            if finished {
                animationView.removeFromSuperview()
            }
        }
    }
    
    
    @objc func ReportTap(_ sender: UIBarButtonItem) {
        if (self.my_view == 0) {
            // UIAlertController
           let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            if (self.favorite_block_status == 1) {
                  let actionChoise1 = UIAlertAction(title: "お気に入り解除", style: .default){
                     action in
                self.favorite_block_status = 99
                  self.userFavoriteBlock(3)
                 }
                alertController.addAction(actionChoise1)
            } else {
                  let actionChoise1 = UIAlertAction(title: "お気に入り", style: .default){
                     action in
                  self.favorite_block_status = 1
                  self.userFavoriteBlock(1)
                 }
                alertController.addAction(actionChoise1)
            }

            if (self.favorite_block_status == 2) {
                 let actionChoise2 = UIAlertAction(title: "ブロック解除", style: .default){
                    action in
                 self.favorite_block_status = 99
                 self.userFavoriteBlock(4)
                }
                alertController.addAction(actionChoise2)
            } else {
                 let actionChoise2 = UIAlertAction(title: "ブロックする", style: .default){
                    action in
                 self.favorite_block_status = 2
                 self.userFavoriteBlock(2)
                }
                alertController.addAction(actionChoise2)
            }
            let actionNoChoise = UIAlertAction(title: "通報する", style: .destructive){
               action in
            self.createReport(self.target_id)
           }
           let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel){
               (action) -> Void in
                print("Cancel")
            }
           // actionを追加

    //       alertController.addAction(actionChoise2)
           alertController.addAction(actionNoChoise)
           alertController.addAction(actionCancel)
           // UIAlertControllerの起動
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func userFavoriteBlock(_ status:Int){
        var setAPIModule: APIModule = POPOAPI.base.createFavoriteBlock
        if (status == 3 || status == 4) {
            setAPIModule = POPOAPI.base.deleteFavoriteBlock
        }
        
        let parameters = [
            "target_id": user_id,
            "status": status
        ] as! [String:Any]
        
        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: ApiStatus) in
                var alert_title = ""
                var alert_text = ""
                // アラート作成
                if status == 2 {
                    alert_title = "ブロック"
                    alert_text = "ブロックしました"
                } else if status == 1 {
                    alert_title = "お気に入り"
                    alert_text = "お気に入りしました"
                } else if status == 3 {
                    alert_title = "お気に入り解除"
                    alert_text = "お気に入り解除しました"
                } else if status == 4 {
                    alert_title = "ブロック解除"
                    alert_text = "ブロック解除しました"
                }
                let alert = UIAlertController(title: alert_title, message: alert_text, preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                // アラート表示
                self.present(alert, animated: true, completion: {
                    // アラートを閉じる
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
            },
            failure: { [self] error in
                print(error)
                // self.errorData = model.errorData;
                // Alert.common(alertNum: self.errorData, viewController: self)
            }
        )
        
        
        //パラメーター
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        query["target_id"] = "\(user_id)"
//        query["status"] = String(status)
//        var headers: HTTPHeaders = [:]
//        var api_key = userDefaults.object(forKey: "api_token") as? String
//        if ((api_key) != nil) {
//            headers = [
//                "Accept" : "application/json",
//                "Authorization" : "Bearer " + api_key!,
//                "Content-Type" : "application/x-www-form-urlencoded"
//            ]
//        }
//        self.requestAlamofire = AF.request(self.requestUrl_1, method: .post, parameters: query, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
//            switch response.result {
//            case .success:
//                var json:JSON;
//                do{
//                    //レスポンスデータを解析
//                    json = try SwiftyJSON.JSON(data: response.data!);
//                } catch {
//                    // error
//                    print("json error: \(error.localizedDescription)");
////                     self.onFaild(response as AnyObject);
//                    break;
//                }
//
//                var alert_title = ""
//                var alert_text = ""
//
//                // アラート作成
//                if status == 2 {
//                    alert_title = "ブロック"
//                    alert_text = "ブロックしました"
//                } else if status == 1 {
//                    alert_title = "お気に入り"
//                    alert_text = "お気に入りしました"
//                } else if status == 3 {
//                    alert_title = "お気に入り解除"
//                    alert_text = "お気に入り解除しました"
//                } else if status == 4 {
//                    alert_title = "ブロック解除"
//                    alert_text = "ブロック解除しました"
//                }
//                let alert = UIAlertController(title: alert_title, message: alert_text, preferredStyle: .alert)
//                let backView = alert.view.subviews.last?.subviews.last
//                backView?.layer.cornerRadius = 15.0
//                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                // アラート表示
//                self.present(alert, animated: true, completion: {
//                    // アラートを閉じる
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                        alert.dismiss(animated: true, completion: nil)
//                    })
//                })
//
//            case .failure:
//                //  リクエスト失敗 or キャンセル時
//                print("リクエスト失敗 or キャンセル時")
//                return;
//            }
//        }
    }

    func createReport(_ target_id:Int){
        if #available(iOS 13.0, *) {
            let contactView = ContactViewController()
            contactView.report_param = ["target_id":String(target_id),"type":1]
            contactView.type = 2
            present(contactView, animated: true, completion: nil)
//            navigationController?.pushViewController(contactView, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
