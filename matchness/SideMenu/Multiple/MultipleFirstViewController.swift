//
//  MultipleFirstViewController.swift
//  matchness
//
//  Created by user on 2019/06/02.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SDWebImage
import DZNEmptyDataSet
import GoogleMobileAds

class MultipleFirstViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    let userDefaults = UserDefaults.standard
    //ここがボタンのタイトルに利用されます
    var activityIndicatorView = UIActivityIndicatorView()
    let dateFormater = DateFormatter()

    var isUpdate = false
    var page_no = 1
    var isLoading:Bool = false
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var refreshControl:UIRefreshControl!
    var status:Int = 0

    
    private var presenter: MultipleInput!
    func inject(presenter: MultipleInput) {
        // このinputがpresenterのこと
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        view.backgroundColor = .white
        self.tableView.register(UINib(nibName: "MultipleTableViewCell", bundle: nil), forCellReuseIdentifier: "MultipleTableViewCell")

//        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        tabBarController?.tabBar.isHidden = true

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        
        tableView.contentInset.bottom = 80
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        let tabBarController: UITabBarController = UITabBarController()
        let tabBarHeight = tabBarController.tabBar.frame.size.height
        bannerView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - tabBarHeight - bannerView.frame.height)
        bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
        bannerView.adUnitID = ApiConfig.ADUNIT_ID // 本番
        bannerView.rootViewController = self;
        let request = GADRequest();
        bannerView.load(request)
        addBannerViewToView(bannerView)
        
        let presenter = MultiplePresenter(view: self)
        inject(presenter: presenter)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        tabBarController?.tabBar.isHidden = true
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y  >= self.tableView.bounds.size.height + 150) && isUpdate == true {
            //ページ更新処理
            isUpdate = false
            self.page_no += 1
            apiRequest()
        }
    }
    
    @objc func refreshTable() {
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        self.page_no = 1
        self.presenter.data = []
        apiRequest()
        self.refreshControl?.endRefreshing()
    }

    func apiRequest() {
        if status == 0 {
            presenter.apiMultiple(self.page_no, POPOAPI.base.foot)
            userDefaults.removeObject(forKey: "footprint")
        }
        if status == 3 {
            presenter.apiMultiple(self.page_no, POPOAPI.base.like)
            userDefaults.removeObject(forKey: "like")
        }
        if status == 6 {
            presenter.apiMylist(self.page_no, 1)
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "データがありません", attributes:stringAttributes)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleTableViewCell") as! MultipleTableViewCell
        if presenter.data.count == 0 {
            return cell
        }
        
        var multiple = presenter.data[indexPath.row]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
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
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = presenter.data[indexPath.row].user_id!
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
        if status == 0 {
            //足跡
             return "相手から"
         } else if status == 3 {
            //いいね
             return "相手から"
         } else if status == 6 {
            //お気に入りブロック
             return "お気にり"
         }
        return ""
    }
}

extension MultipleFirstViewController: MultipleOutput {
    func update(page: Int, isUpdate: Bool) {
        self.isUpdate = isUpdate
        self.page_no = page
        self.activityIndicatorView.stopAnimating()
        self.tableView.reloadData()
    }

    func error() {}
}
