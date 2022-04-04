//
//  ChatSecondViewController.swift
//  matchness
//
//  Created by user on 2019/06/02.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import GoogleMobileAds

class ChatSecondViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var tableView: UITableView!
    let userDefaults = UserDefaults.standard
    var dataSource = [ApiMessage]()
    var dataMessage = [ApiMessageList]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let dateFormater = DateFormatter()
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var page_no = 1
    var isUpdate = false
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        self.tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)

        tableView.contentInset.bottom = 80
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        let bHeight :CGFloat = 70
        bannerView.frame = CGRect(x: 0 , y: self.view.frame.size.height-bHeight, width: self.view.frame.width, height: bHeight - 1)
        bannerView.adUnitID = ApiConfig.ADUNIT_ID // 本番
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // テスト
        bannerView.rootViewController = self;
        let request = GADRequest();
        bannerView.load(request)
        addBannerViewToView(bannerView)
        
        apiRequest()
    }


    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    
    
    @objc func refreshTable() {
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        self.page_no = 1
        dataSource = []
        dataMessage = []
        apiRequest()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
        if let tabBarItem = self.tabBarController?.tabBar.items?[3] as? UITabBarItem {
            tabBarItem.badgeValue = nil
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
    }
    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "page_no" : self.page_no,
            "status": 0,
            "message_type": 1
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectMatche, parameters: parameters,success: { [self] (response: [ApiMessage]) in
            dataSource = response
            isUpdate = response.count < 5 ? false : true
            dataMessage.append(contentsOf: dataSource[0].message)
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= self.tableView.bounds.size.height + 150) && isUpdate == true {
            isUpdate = false
            self.page_no += 1
            apiRequest()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataMessage.count
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "マッチングすると\nこの画面で確認できます", attributes:stringAttributes)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        if dataMessage.count != 0 {
            var message = dataMessage[indexPath.row]

            cell.ChatName.text = message.target_name
            
            dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let date = dateFormater.date(from: message.created_at!)
            dateFormater.dateFormat = "MM/dd HH:mm"
            let date_text = dateFormater.string(from: date ?? Date())
            cell.ChatDate.text = String(date_text)
            cell.ChatMessage.text = "マッチングしました。"

            if (message.profile_image == nil) {
                cell.ChatImage.image = UIImage(named: "no_image")
            } else {
                let profileImageURL = image_url + (message.profile_image!)
                cell.ChatImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }

            cell.ChatImage.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage(_:)))
            recognizer.targetUserId = Int(message.target_id!)
            cell.ChatImage.addGestureRecognizer(recognizer)
            cell.ChatImage.contentMode = .scaleAspectFill
            cell.ChatImage.clipsToBounds = true
            cell.ChatImage.layer.cornerRadius =  cell.ChatImage.frame.height / 2
            cell.tag = indexPath.row
            return cell
        }
        return cell
    }

    @objc func onTapImage(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "マッチング"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = tableView.cellForRow(at: indexPath)
        let message_id = selectedCell?.tag ?? 0
        
        var users = dataSource[0].message[message_id]

        let message_users:[String:String] = [
            "room_code":String(users.room_code!),
            "user_id":String(dataSource[0].id!),
            "user_name":dataSource[0].name!,
            "point":String(dataSource[0].point!),
            "sex":String(dataSource[0].sex!),
            "my_image":dataSource[0].profile_image!,
            "target_imag":users.profile_image!,
            "target_name":users.target_name!,
        ]

        let vc = UIStoryboard(name: "ChatMessage", bundle: nil).instantiateInitialViewController()! as! ChatMessageViewController
        vc.message_users = message_users
        navigationController?.pushViewController(vc, animated: true)
    }
}
