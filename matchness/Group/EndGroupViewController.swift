//
//  EndGroupViewController.swift
//  matchness
//
//  Created by user on 2019/06/03.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import SDWebImage
import DZNEmptyDataSet

class EndGroupViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    var group_id: Int = 0
    var dataSource = [ApiGroupList]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var status = 1
    var isLoading:Bool = false
    var isUpdate = false
    var page_no = 1
    var refreshControl:UIRefreshControl!
    
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
        apiRequest()

    }

    @objc func refreshTable() {
        // 更新処理
        self.isLoading = true
        self.page_no = 1
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        var dataSource: Dictionary<String, ApiGroupList> = [:]
        apiRequest()
        self.refreshControl?.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.isLoading = true
        self.page_no = 1
        dataSource = []
        super.viewWillAppear(animated)
        apiRequest()
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
    }

    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "status": "3",
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
        return NSAttributedString(string: "参加済のグループはありません", attributes:stringAttributes)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        if dataSource.count == 0 {
            return cell
        }
        var eventGroup = dataSource[indexPath.row]
        if eventGroup != nil {
            cell.titel.text = eventGroup.title!
            cell.period.text = "開催期間 : " + ApiConfig.EVENT_PERIOD_LIST[(eventGroup.event_period)]
            cell.joinNumber.text = "参加人数 : " +  ApiConfig.EVENT_PEPLE_LIST[(eventGroup.event_peple)]
    //        cell.startType.text = "開始 : " +  ApiConfig.EVENT_START_TYPE[(eventGroup?.start_type)!]
            cell.presentPoint.text = "賞金 : " +  ApiConfig.PRESENT_POINT[(eventGroup.present_point)] + "P"

            cell.joinButton.setTitle("参加済", for: .normal)
            cell.joinButton.layer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 1.0).cgColor

            self.status = eventGroup.status as! Int
            cell.joinButton.layer.cornerRadius = 5.0 //丸みを数値で変更できます
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.indexRow = indexPath.row
            recognizer.targetGroupId = eventGroup.id
            cell.joinButton.layer.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            cell.joinButton.addGestureRecognizer(recognizer)

            if (eventGroup.profile_image == nil) {
                cell.groupTestImage.image = UIImage(named: "no_image")
            } else {
                let profileImageURL = image_url + (eventGroup.profile_image!)
                cell.groupTestImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }

            cell.groupTestImage.isUserInteractionEnabled = true
            var recognizer_1 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage(_:)))
            recognizer_1.targetUserId = eventGroup.master_id
            cell.groupTestImage.addGestureRecognizer(recognizer_1)
        }
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
            "status":String(self.status),
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
