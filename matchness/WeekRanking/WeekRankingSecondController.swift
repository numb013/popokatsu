//
//  NewGroupPepleViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/04/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CoreMotion
import HealthKit
import SDWebImage
import XLPagerTabStrip

class WeekRankingSecondController: UIViewController, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var myStep: UILabel!
    @IBOutlet weak var myRank: UILabel!
    @IBOutlet weak var kikan: UILabel!
    
    
    var headerViewMaxHeight: CGFloat!
    let headerViewMinHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    var activityIndicatorView = UIActivityIndicatorView()
    let userDefaults = UserDefaults.standard

    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var dataSource = [ApiWeekRanking]()
    var dataEventList = [ApiWeekRankList]()
    
    var dataSourceOrder: Array<String> = []
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let dateFormater = DateFormatter()
    var isUpdate = false
    var page_no = 1

    var refreshControl:UIRefreshControl!

    let dateFormatter = DateFormatter()
    let now = Date()
    let store = HKHealthStore()
    var selectDate_start = ""
    var selectDate_end = ""
    var start = Date()
    var end = Date()
    var week_step = 0

    var this_end = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes: Set<HKObjectType> = [
             HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!
            ]
            // 許可されているかどうかを確認
            store.requestAuthorization(toShare: nil, read: readDataTypes as? Set<HKObjectType>) {
                (success, error) -> Void in
            }
        } else{
            Alert.helthError(alertNum: self.errorData, viewController: self)
        }
        
        self.tableView.register(UINib(nibName: "NewGroupPepleTableViewCell", bundle: nil), forCellReuseIdentifier: "NewGroupPepleTableViewCell")
        tabBarController?.tabBar.isHidden = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.contentInset.bottom = 100
        tableView.addSubview(self.refreshControl)
        
        activityIndicatorView.startAnimating()

        setupHeaderView()
        
        // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
        kikan.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        // 影の色
        kikan.layer.shadowColor = UIColor.black.cgColor
        // 影の濃さ
        kikan.layer.shadowOpacity = 0.1
        // 影をぼかし
        kikan.layer.shadowRadius = 2
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = []
        dataEventList = []
        getStepWeekDate()
    }
    
    
    fileprivate func getHeightOfHeaderView() -> CGFloat {
        return CGFloat(headerView.frame.height)
    }
    
    fileprivate func setupHeaderView() {
        headerView.clipsToBounds = true
        headerViewMaxHeight = getHeightOfHeaderView()
        headerViewHeightConstraint.constant = headerViewMaxHeight
    }
    
    fileprivate func changeViewsAlpha(_ y: CGFloat) {
        let totalScroll: CGFloat = 25.0
        let percentage = y / totalScroll
    }
    
    @objc func refreshTable() {
        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        self.page_no = 1
        
        dataSource = []
        dataEventList = []
        getStepWeekDate()
        self.refreshControl?.endRefreshing()
    }
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let y: CGFloat = scrollView.contentOffset.y
        changeViewsAlpha(y)
        
        let newHeaderViewHeight: CGFloat = headerViewHeightConstraint.constant - y
        if newHeaderViewHeight > headerViewMaxHeight {
            print("111111111")
            headerViewHeightConstraint.constant = headerViewMaxHeight
        } else if newHeaderViewHeight < headerViewMinHeight {
            print("222222222")
            headerViewHeightConstraint.constant = headerViewMinHeight
        } else {
            print("333333333")
            headerViewHeightConstraint.constant = newHeaderViewHeight
            scrollView.contentOffset.y = 0
        }
    }
    
    func getStepWeekDate() {
        getWeekStep { (result) in
            DispatchQueue.main.async {
                self.week_step = Int(result)
                self.myStep.text = String(self.week_step)
                self.apiRequest()
            }
        }
    }

    // 今日の歩数を取得するための関数
    func getWeekStep(completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        dateFormatter.dateFormat = "MM月dd日"
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEEE", options: 0, locale:  Locale.current)

        self.this_end = Calendar.current.endOfWeek(for: now)
        self.start = Calendar.current.startOfWeek(for: now)
        self.end = self.this_end
//            var end_1 = calendar.date(byAdding: .day, value: -1, to: Calendar.current.endOfWeek(for: now))!
        //日付の文字列作成
        self.start = Calendar.current.date(byAdding: .day, value: -7, to: self.start)!
        var week_st = formatter.string(from: self.start as Date)
        self.selectDate_start = "\(dateFormatter.string(from: self.start) + "(" + week_st + ")")"

        self.end = Calendar.current.date(byAdding: .day, value: -7, to: self.end)!
        self.end = Calendar.current.date(byAdding: .second, value: -1, to: self.end)!
        var week_end = formatter.string(from: self.end as Date)
        self.selectDate_end = "\(dateFormatter.string(from: self.end) + "(" + week_end + ")")"
        kikan.text = self.selectDate_start + " ~ " + self.selectDate_end

        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: self.start as Date, end: self.end as Date, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .separateBySource) { (query, data, error) in
            if let sources = data?.sources?.filter({ $0.bundleIdentifier.hasPrefix("com.apple.health") }) {
                let sourcesPredicate = HKQuery.predicateForObjects(from: Set(sources))
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sourcesPredicate])
                let query = HKStatisticsQuery(quantityType: type,
                                              quantitySamplePredicate: predicate,
                                              options: .cumulativeSum)
                { (query, statistics, error) in
                    var value: Double = 0
                    if error != nil {
                        print("something went wrong")
                    } else if let quantity = statistics?.sumQuantity() {

                        value = quantity.doubleValue(for: HKUnit.count())
                        completion(value)
                    }
                }
                self.store.execute(query)
            }
        }
        store.execute(query)
    }

    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        
        print("スターーーーと", self.start)
        print("エンドーーーーと", self.end)
        
        let parameters = [
            "start": dateFormatter.string(from: self.start),
            "end": dateFormatter.string(from: self.end),
            "step": self.week_step,
            "page": 1
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectWeekRank, parameters: parameters,success: { [self] (response: [ApiWeekRanking]) in
                dataSource = response
            dataEventList.append(contentsOf: dataSource[0].week_rank_list)
                self.activityIndicatorView.stopAnimating()
                if dataSource[0].rank == nil {
                    myRank.text = "圏外"
                } else {
                    myRank.text = String((dataSource[0].rank)) + "位"
                }

                tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "先週"
    }
    
        
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "現在参加者がいません", attributes:stringAttributes)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataEventList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var week = dataEventList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewGroupPepleTableViewCell") as! NewGroupPepleTableViewCell

        if (week.profile_image == nil) {
            cell.userImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (week.profile_image)
            cell.userImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }

        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.cornerRadius =  cell.userImage.frame.height / 2
        cell.userImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        recognizer.targetUserId = week.user_id
        cell.userImage.addGestureRecognizer(recognizer)

        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let date = dateFormater.date(from: week.action_datetime as! String)
        dateFormater.dateFormat = "MM/dd HH:mm"
        let date_text = dateFormater.string(from: date ?? Date())

        cell.lastLoginTime.text = "ログイン：" + date_text
        var name = week.name
        var age = "\(week.age) 歳"
        var prefecture = ApiConfig.PREFECTURE_LIST[week.prefecture_id ?? 0]
        cell.userInfo?.adjustsFontSizeToFitWidth = true
        cell.userInfo?.numberOfLines = 0
        cell.userInfo.text = name + " " + age + prefecture
        cell.userStep.text = "\(week.step)"
        cell.rank.text = String(indexPath.row + 1)
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.rank.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.userStep.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        if indexPath.row == 0 {
            cell.userStep.textColor = .popoGold
            cell.rank.textColor = .popoGold
        }
        if indexPath.row == 1 {
            cell.userStep.textColor = .popoSilver
            cell.rank.textColor = .popoSilver
        }
        if indexPath.row == 2 {
            cell.userStep.textColor = .popoBronze
            cell.rank.textColor = .popoBronze
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        }
        return 110
    }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }
}
