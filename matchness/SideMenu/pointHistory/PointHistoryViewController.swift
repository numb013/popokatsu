//
//  PointHistoryViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/09/22.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class PointHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let userDefaults = UserDefaults.standard
    var pont: Int = 0

    //ApiPintHistoryList
//    var cellCount: Int = 0
//    var dataSource: Dictionary<String, ApiPintHistoryList> = [:]
//    var dataSourceOrder: Array<String> = []
//    var errorData: Dictionary<String, ApiErrorAlert> = [:]
//    var notice_id: Int = 0
//    var selectRow = 0
    let dateFormater = DateFormatter()
    var dataSource = [ApiPintHistoryList]()

    @IBOutlet weak var myPoint: UILabel!    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        // Do any additional setup after loading the view.
        
        self.tableView.register(UINib(nibName: "PointHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "PointHistoryTableViewCell")
        
        self.navigationItem.title = "ポイント履歴"
//        navigationController!.navigationBar.topItem!.title = ""
        tabBarController?.tabBar.isHidden = true
        tableView.tableFooterView = UIView(frame: .zero)
        
        apiRequest()
    }
    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        API.requestHttp(POPOAPI.base.pointHistory, parameters: nil,success: { [self] (response: [ApiPintHistoryList]) in
                dataSource = response
                tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
        returnView()
        tableView.reloadData()
    }

    func returnView() {
        var detail = self.dataSource[0]
        self.pont = self.userDefaults.object(forKey: "point") as! Int
        myPoint.text = String(self.pont)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "まだポイント履歴はありません", attributes:stringAttributes)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var notice = self.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointHistoryTableViewCell") as! PointHistoryTableViewCell

        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = dateFormater.date(from: (notice.created_at!))

        dateFormater.dateFormat = "MM/dd HH:mm"
        let date_text = dateFormater.string(from: date ?? Date())
        cell.created?.text = String(date_text)

        var status = Int((notice.status)!)
        print("statusstatusstatus")
        print(status)

        cell.title?.text = ApiConfig.POINT_HISTORY[status]
        cell.point?.text = notice.point
        if ((notice.status)! <= 4) {
            cell.point?.textColor = .popoPink
            cell.p_text.textColor = .popoPink
        } else {
            cell.point?.textColor = .popoTextGreen
            cell.p_text.textColor = .popoTextGreen
        }

        //cell.detail?.text = ApiConfig.BLOOD_LIST[myData?.blood_type ?? 2]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
