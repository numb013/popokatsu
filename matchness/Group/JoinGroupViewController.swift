//
//  JoinGroupViewController.swift
//  matchness
//
//  Created by user on 2019/06/03.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import SDWebImage
import DZNEmptyDataSet


class JoinGroupViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var group_id: Int = 0
    var dataSource = [ApiGroupList]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var status = 1
    var isUpdate:Bool = false
    var page_no = 1
    var refreshControl:UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

        self.tableView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        self.navigationItem.title = "グループ"
    }

    @objc func goAddGroup(_ sender : Any) {
        let vc = UIStoryboard(name: "GroupEvent", bundle: nil).instantiateViewController(withIdentifier: "GroupEventAdd")
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func refreshTable() {
        // 更新処理
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
        self.page_no = 1
        dataSource = []
        apiRequest()
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
    }

    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "status": "1",
            "page": self.page_no
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectJoinAndEndGroup, parameters: parameters,success: { [self] (response: [ApiGroupList]) in
            isUpdate = response.count < 5 ? false : true
            dataSource.append(contentsOf: response)
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
        return NSAttributedString(string: "参加中のグループはありません", attributes:stringAttributes)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        if dataSource.count == 0 {
            return cell
        }
        var joinGroup = dataSource[indexPath.row]
        cell.titel.text = joinGroup.title!
        cell.period.text = "開催期間 : " + ApiConfig.EVENT_PERIOD_LIST[(joinGroup.event_period)]
        cell.joinNumber.text = "参加人数 : " +  ApiConfig.EVENT_PEPLE_LIST[(joinGroup.event_peple)]
//        cell.startType.text = "開始 : " +  ApiConfig.EVENT_START_TYPE[(joinGroup?.start_type)]
        cell.presentPoint.text = "賞金 : " +  ApiConfig.PRESENT_POINT[(joinGroup.present_point)] + "P"

        self.status = joinGroup.status as! Int
        if joinGroup.status == 1 {
            cell.joinButton.setTitle("参加中", for: .normal)
            cell.joinButton.layer.backgroundColor = #colorLiteral(red: 1, green: 0.6352941176, blue: 0, alpha: 1)
        } else if joinGroup.status == 2 {
            cell.joinButton.setTitle("集計中", for: .normal)
            cell.joinButton.layer.backgroundColor = #colorLiteral(red: 0.2771535814, green: 0.7673208714, blue: 0.2277948558, alpha: 1)
        }
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        recognizer.indexRow = indexPath.row
        recognizer.targetGroupId = joinGroup.id
        cell.joinButton.layer.cornerRadius = 5.0 //丸みを数値で変更できます
        cell.joinButton.addGestureRecognizer(recognizer)
        
        if (joinGroup.profile_image == nil) {
            cell.groupTestImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (joinGroup.profile_image!)
            cell.groupTestImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }
        cell.groupTestImage.isUserInteractionEnabled = true
        var recognizer_1 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage(_:)))
        recognizer_1.targetUserId = joinGroup.master_id
        cell.groupTestImage.addGestureRecognizer(recognizer_1)

        return cell
    }

    @objc func onTapImage(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        let vc = UIStoryboard(name: "Group", bundle: nil).instantiateInitialViewController()! as! GroupEventViewController
        self.group_id = sender.targetGroupId!
        let group_param:[String:Any] = [
            "group_id":self.group_id,
            "group_status":self.status,
            "status":"2",
            "start": self.dataSource[sender.indexRow!].event_start,
            "end": self.dataSource[sender.indexRow!].event_end
        ]
        vc.group_param = group_param
        navigationController?.pushViewController(vc, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let udc:UserDetailViewController = segue.destination as! UserDetailViewController
            udc.user_id = sender as! Int
        } else {
            let vc = segue.destination as! GroupEventViewController
            vc.group_param = sender as! [String : Any]
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
