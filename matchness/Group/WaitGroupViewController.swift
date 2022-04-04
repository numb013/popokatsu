//
//  WaitGroupViewController.swift
//  matchness
//
//  Created by user on 2019/06/03.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import SDWebImage
import DZNEmptyDataSet

class WaitGroupViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    var activityIndicatorView = UIActivityIndicatorView()
    var dataSource = [ApiGroupList]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var isUpdate = false
    var page_no = 1
    var group_id: Int = 0
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var event_peple: String? = nil
    var event_period: String? = nil
    var present_point: String? = nil
    var group_flag: String? = nil
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)

        self.tableView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
        self.navigationItem.title = "参加希望待ち"
        apiRequest()
        tableView.tableFooterView = UIView(frame: .zero)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        
        self.tableView.contentInset.bottom = 110
        self.navigationItem.title = "グループ"
    }

    
    @objc func refreshTable() {

        self.page_no = 1
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        dataSource = []
        apiRequest()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        self.page_no = 1
        dataSource = []
        apiRequest()
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
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
        return NSAttributedString(string: "募集中のグループはありません", attributes:stringAttributes)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell

        if dataSource.count == 0 {
            return cell
        }
        var waitGroup = dataSource[indexPath.row]
        cell.titel.text = waitGroup.title!
        cell.period.text = "開催期間 : " + ApiConfig.EVENT_PERIOD_LIST[(waitGroup.event_period)]
        cell.joinNumber.text = "参加人数 : " +  ApiConfig.EVENT_PEPLE_LIST[(waitGroup.event_peple)]
        cell.presentPoint.text = "賞金 : " +  ApiConfig.PRESENT_POINT[waitGroup.present_point] + "P"
        if waitGroup.request_number != nil {
            cell.requestNumber.text =  "希望数: \(waitGroup.request_number!) 人"
        } else {
            cell.requestNumber.text = "希望数: 0人"
        }
        cell.groupFlag.image = UIImage(named: "new3")

        var number_button = waitGroup.request_status

        if ((waitGroup.master_group) != nil) {
            cell.joinButton.setTitle("主催グループ", for: .normal)
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.targetString = "3"
            recognizer.targetGroupId = waitGroup.id
            cell.joinButton.layer.backgroundColor =  #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
            cell.joinButton.addGestureRecognizer(recognizer)
        } else {
            if (number_button == 1 || number_button == 2) {
                cell.joinButton.setTitle("参加希望中", for: .normal)
                var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                recognizer.targetString = "1"
                recognizer.targetGroupId = waitGroup.id
                cell.joinButton.layer.backgroundColor =  #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
                cell.joinButton.addGestureRecognizer(recognizer)
            } else if (number_button == nil) {
                cell.joinButton.setTitle("募集中", for: .normal)
                var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                recognizer.targetString = "0"
                recognizer.targetGroupId = waitGroup.id
                cell.joinButton.layer.backgroundColor =  #colorLiteral(red: 1, green: 0.194529444, blue: 0.5957843065, alpha: 1)
                cell.joinButton.addGestureRecognizer(recognizer)
            }
        }

        //cell.joinButton.layer.backgroundColor = UIColor(red: 254/255, green: 0, blue: 124/255, alpha: 1).cgColor
        cell.joinButton.layer.cornerRadius = 5.0 //丸みを数値で変更できます

        if (waitGroup.profile_image == nil) {
            cell.groupTestImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (waitGroup.profile_image!)
            cell.groupTestImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }

        cell.groupTestImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage(_:)))
        recognizer.targetUserId = waitGroup.master_id
        cell.groupTestImage.addGestureRecognizer(recognizer)

        return cell
    }

    @objc func onTapImage(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toDetail" {
            let udc:UserDetailViewController = segue.destination as! UserDetailViewController
            udc.user_id = sender as! Int
        }
    }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        self.group_id = sender.targetGroupId!
        var tap_number = sender.targetString!
        if (tap_number == "3") {
            let vc = PreferredGroupList()
            vc.group_id = group_id
            navigationController?.pushViewController(vc, animated: true)
        } else if (tap_number == "1"){
            let alertController:UIAlertController =
                UIAlertController(title:"キャンセルする",message: "本当にキャンセルしますか？",preferredStyle: .alert)
            let backView = alertController.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            // Default のaction
            let defaultAction:UIAlertAction =
                UIAlertAction(title: "キャンセルする",style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                    self.activityIndicatorView.startAnimating()
                    self.requestJoin(status:"0")
                })
            // Cancel のaction
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "閉じる",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                })
            cancelAction.setValue(#colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), forKey: "titleTextColor")
            defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
            // actionを追加
            alertController.addAction(cancelAction)
            alertController.addAction(defaultAction)
            // UIAlertControllerの起動
            present(alertController, animated: true, completion: nil)
        } else if (tap_number == "0"){
            let alertController:UIAlertController =
                UIAlertController(title:"参加希望する",message: "本当に参加希望しますか？",preferredStyle: .alert)
            let backView = alertController.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            // Default のaction
            let defaultAction:UIAlertAction =
                UIAlertAction(title: "参加希望する",style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                    self.activityIndicatorView.startAnimating()
                    self.requestJoin(status:"1")
                })
            // Cancel のaction
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                })
            cancelAction.setValue(#colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), forKey: "titleTextColor")
            defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
            // actionを追加
            alertController.addAction(cancelAction)
            alertController.addAction(defaultAction)
            // UIAlertControllerの起動
            present(alertController, animated: true, completion: nil)
        }
    }

    
    @IBAction func groupQuetion(_ sender: Any) {
        let alarmsListVC = storyboard!.instantiateViewController(withIdentifier: "version") as? VersionViewController
//        alarmsListVC.modalPresentationStyle = .fullScreen
        alarmsListVC!.status = 1
        present(alarmsListVC!, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "status": 0,
            "page": self.page_no,
            "freeword": userDefaults.object(forKey: "searchGroupFreeword"),
            "event_peple": userDefaults.object(forKey: "searchEventPeple"),
            "event_period": userDefaults.object(forKey: "searchEventPeriod"),
            "present_point": userDefaults.object(forKey: "searchPresentPoint"),
            "group_flag": userDefaults.object(forKey: "searchGroupFlag")
        ] as [String:Any]

        API.requestHttp(POPOAPI.base.searchGroup, parameters: parameters,success: { [self] (response: [ApiGroupList]) in
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

    func requestJoin(status: String) {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "group_id": self.group_id,
            "status": status,
            "type": 1,
            "page": 1,
            "freeword": userDefaults.object(forKey: "searchGroupFreeword"),
            "event_peple": userDefaults.object(forKey: "searchEventPeple"),
            "event_period": userDefaults.object(forKey: "searchEventPeriod"),
            "present_point": userDefaults.object(forKey: "searchPresentPoint"),
            "group_flag": userDefaults.object(forKey: "searchGroupFlag"),
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.searchGroup, parameters: parameters,success: { [self] (response: [ApiGroupList]) in
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
}
