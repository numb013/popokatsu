//
//  GroupNoticeViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class poinChangeRankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{

    let userDefaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    
//    let dateFormater = DateFormatter()
//    var cellCount: Int = 0
//    var errorData: Dictionary<String, ApiErrorAlert> = [:]
//    var dataSource: Dictionary<String, ApiPoinChangeRank> = [:]
//    var dataSourceOrder: Array<String> = []
//    var isLoading:Bool = false
//    var isUpdate = false
//    var page_no = "1"
//    var selectRow = 0
//    var body = ""
    var refreshControl:UIRefreshControl!
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var dataSource = [ApiPoinChangeRank]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "poinChangeRankTableViewCell", bundle: nil), forCellReuseIdentifier: "poinChangeRankTableViewCell")

        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension

        userDefaults.set(0, forKey: "notice")
        tableView.tableFooterView = UIView(frame: .zero)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        apiRequest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "お知らせ"
    }

    @objc func refreshTable() {
//        self.isLoading = true
//        if self.isUpdate == false {
//            self.isUpdate = true
//        } else {
//            self.isUpdate = false
//        }
//        self.page_no = "1"
        self.dataSource = []
        apiRequest()
        self.refreshControl?.endRefreshing()
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
//        /****************
//         APIへリクエスト（ユーザー取得）
//         *****************/  
        API.requestHttp(POPOAPI.base.pointRank, parameters: nil,success: { [self] (response: [ApiPoinChangeRank]) in
                dataSource = response
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
        return NSAttributedString(string: "表示できる\nデータがありません", attributes:stringAttributes)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "設定"
//    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        header.tintColor = #colorLiteral(red: 0.9499146342, green: 0.9500735402, blue: 0.9498936534, alpha: 1)
//        header.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var point_rank = self.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "poinChangeRankTableViewCell") as! poinChangeRankTableViewCell
        if (point_rank.profile_image == nil) {
            cell.userImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (point_rank.profile_image!)
            cell.userImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }
        cell.userImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        recognizer.targetUserId = point_rank.user_id
        cell.userImage.addGestureRecognizer(recognizer)
        var age = (point_rank.age!) + "歳 "
        cell.rank?.text = point_rank.rank
        cell.name_text?.text = (point_rank.name)! + " " + age
        cell.prefecter.text = ApiConfig.PREFECTURE_LIST[point_rank.prefecture_id ?? 0]
        cell.tag = indexPath.row

        return cell
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var user_id = self.dataSource[indexPath.row].user_id
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id!
        navigationController?.pushViewController(vc, animated: true)
    }
}
