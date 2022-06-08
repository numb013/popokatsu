//
//  AllNoticeViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

@available(iOS 13.0, *)
class AllNoticeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    //    var cellCount: Int = 0
    //    var dataSourceOrder: Array<String> = []
    //    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    //    var isLoading:Bool = false
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    let dateFormater = DateFormatter()
    var dataSource = [ApiNoticeList]()
    var isUpdate = false
    var page_no = 1
    var body = ""
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "NoticeTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeTableViewCell")
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension
        userDefaults.set(0, forKey: "notice")
        tableView.tableFooterView = UIView(frame: .zero)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "お知らせ"
        dataSource = []
        print("更新１１１")
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
        print("更新２２２")
        apiRequest()
        self.refreshControl?.endRefreshing()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= tableView.contentSize.height - self.tableView.bounds.size.height)  && isUpdate == true {
            //ページ更新処理
            isUpdate = false
            self.page_no += 1
            print("更新３３３")
            apiRequest()
        }
    }

    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "page": self.page_no
        ] as! [String: Any]
        API.requestHttp(POPOAPI.base.notice, parameters: parameters,success: { [self] (response: [ApiNoticeList]) in
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
        return NSAttributedString(string: "まだお知らせはありません", attributes:stringAttributes)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell") as! NoticeTableViewCell
        if dataSource.count == 0 {
            return cell
        }
        var notice = self.dataSource[indexPath.row]
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = dateFormater.date(from: (notice.created_at!))
        dateFormater.dateFormat = "MM/dd HH:mm"
        let date_text = dateFormater.string(from: date ?? Date())
        cell.dateTime?.text = String(date_text)
        cell.noticeText?.text = notice.title
        cell.tag = indexPath.row
        cell.noticeText?.adjustsFontSizeToFitWidth = true
        cell.noticeText?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var notice = self.dataSource[indexPath.row]

        print("okokokokokokokok")
        dump(notice)
        
        //グループ
        if notice.type == 3 {
            if notice.sub_type == 1 {//参加希望
                let vc = PreferredGroupList()
                vc.group_id = (notice.target_id)!
                self.navigationController?.pushViewController(vc, animated: true)
            } else if notice.sub_type == 2 {//チャット
                let vc = GroupChat()
                vc.group_id = (notice.target_id)!
                vc.status = 2
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                var row = selectedCell?.tag ?? 0
                self.body = self.dataSource[row].body_text as! String
                self.performSegue(withIdentifier: "toNoticeDetail", sender: nil)
            }
        }

        if notice.type == 4 {
            if notice.sub_type == 1 {//いいね
                let vc = TweetDetailViewController()
                vc.tweet_id = (notice.target_id)!
                navigationController?.pushViewController(vc, animated: true)
            } else if notice.sub_type == 2 {//コメント
                let vc = TweetDetailViewController()
                vc.tweet_id = (notice.target_id)!
                navigationController?.pushViewController(vc, animated: true)
            } else {
                var row = selectedCell?.tag ?? 0
                self.body = self.dataSource[row].body_text as! String
                self.performSegue(withIdentifier: "toNoticeDetail", sender: nil)
            }
        }
        if notice.type != 3 && notice.type != 4 {
            var row = selectedCell?.tag ?? 0
            self.body = self.dataSource[row].body_text as! String
            self.performSegue(withIdentifier: "toNoticeDetail", sender: nil)
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNoticeDetail" {
            let nextVC = segue.destination as! NoticeDetailViewController
            nextVC.body = self.body
        }
    }
}
