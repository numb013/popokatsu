//
//  TweetLikeListViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/01/28.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SDWebImage
import DZNEmptyDataSet

class TweetLikeListViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //ここがボタンのタイトルに利用されます
    @IBOutlet weak var tableView: UITableView!
    var activityIndicatorView = UIActivityIndicatorView()
    var dataSource = [ApiMultipleUser]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let dateFormater = DateFormatter()
    let userDefaults = UserDefaults.standard
    var isUpdate = false
    var page_no = 1
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var refreshControl:UIRefreshControl!
    var tweet_id = Int()
    var type = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

        self.tableView.register(UINib(nibName: "MultipleTableViewCell", bundle: nil), forCellReuseIdentifier: "MultipleTableViewCell")

        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        tabBarController?.tabBar.isHidden = true

        activityIndicatorView.center = tableView.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        navigationController!.navigationBar.topItem!.title = ""
        self.navigationItem.title = "いいねした人"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        tabBarController?.tabBar.isHidden = true
        dataSource = []
        apiRequest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicatorView.startAnimating()
        tabBarController?.tabBar.isHidden = true
    }
    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "tweet_id": self.tweet_id,
            "status": 1,
            "type": type
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.likeTweetList, parameters: parameters,success: { [self] (response: [ApiMultipleUser]) in
            isUpdate = response.count < 5 ? false : true
            dataSource.append(contentsOf: response)
            self.activityIndicatorView.stopAnimating()
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= tableView.contentSize.height - self.tableView.bounds.size.height)  && isUpdate == true {
            isUpdate = false
            self.page_no += 1
            apiRequest()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "データがありません", attributes:stringAttributes)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleTableViewCell") as! MultipleTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        var multiple = self.dataSource[indexPath.row]

        cell.userName.text = multiple.name!
        cell.userWork.text = ApiConfig.PREFECTURE_LIST[multiple.prefecture_id ?? 0]

        if (multiple.profile_image == nil) {
            cell.userImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (multiple.profile_image!)
            cell.userImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }

        cell.userImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        recognizer.targetUserId = multiple.user_id
        cell.userImage.addGestureRecognizer(recognizer)

        dateFormater.dateFormat = "MM/dd HH:mm"
        let formatter = DateFormatter()
        let now = multiple.created_at ?? ""
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        let date = formatter.date(from: now)
        let date_text = dateFormater.string(from: date ?? Date())
        cell.createTime.text = String(date_text)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var user_id = self.dataSource[indexPath.row].user_id
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return ""
    }
}
