//
//  WeekRankingController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/06/30.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SDWebImage
import CoreMotion
import HealthKit
import XLPagerTabStrip

class WeekRankingController: UIViewController, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "今週"
    @IBOutlet weak var tableView: UITableView!
    var activityIndicatorView = UIActivityIndicatorView()
    let userDefaults = UserDefaults.standard
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var dataSource = [ApiWeekRanking]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let dateFormater = DateFormatter()
    var isUpdate = false
    var page_no = 1
    var refreshControl:UIRefreshControl!
    
    let dateFormatter = DateFormatter()
    let store = HKHealthStore()
    var selectDate_start = ""
    var selectDate_end = ""
    var start = Date()
    var end = Date()
    var week_step = 0
    let now = Date()
    var this_end = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        self.tableView.register(UINib(nibName: "NewGroupPepleTopTableViewCell", bundle: nil), forCellReuseIdentifier: "NewGroupPepleTopTableViewCell")
        self.tableView.allowsSelection = false
        tabBarController?.tabBar.isHidden = false

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.contentInset.bottom = 100
        tableView.addSubview(self.refreshControl)
        
        activityIndicatorView.startAnimating()
        getStepWeekDate()
    }
    
    @objc func refreshTable() {

        if self.isUpdate == false {
            self.isUpdate = true
        } else {
            self.isUpdate = false
        }
        self.page_no = 1

        dataSource = []
        getStepWeekDate()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "今週"
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (!self.isUpdate) {
//            if (!self.isLoading && scrollView.contentOffset.y >= tableView.contentSize.height - self.tableView.bounds.size.height) {
//                self.isLoading = true
//                apiRequest()
//            }
//        }
//    }
    
    func getStepWeekDate() {
        getWeekStep { (result) in
            DispatchQueue.main.async {
                self.week_step = Int(result)

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

        self.start = Calendar.current.startOfWeek(for: now)
        self.this_end = Calendar.current.endOfWeek(for: now)
        self.end = self.this_end
//            var end_1 = calendar.date(byAdding: .day, value: -1, to: Calendar.current.endOfWeek(for: now))!
        //日付の文字列作成
//        self.start = Calendar.current.date(byAdding: .day, value: 1, to: self.start)!
        var week_st = formatter.string(from: self.start as Date)
        self.selectDate_start = "\(dateFormatter.string(from: self.start) + "(" + week_st + ")")"

            self.end = Calendar.current.date(byAdding: .day, value: -1, to: self.end)!
        var week_end = formatter.string(from: self.end as Date)
        self.selectDate_end = "\(dateFormatter.string(from: self.end) + "(" + week_end + ")")"

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
        let parameters = [
            "start": dateFormatter.string(from: self.start),
            "end": dateFormatter.string(from: self.end),
            "step": String(self.week_step),
            "page": 1
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectWeekRank, parameters: parameters,success: { [self] (response: [ApiWeekRanking]) in
            dataSource.append(contentsOf: response)
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewGroupPepleTopTableViewCell") as! NewGroupPepleTopTableViewCell
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
