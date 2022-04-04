//
//  RankUpViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/04/15.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit
import HealthKit

struct rankParam: Codable {
    let now_rank: Int
}

class RankUpViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, StepMasterDelegate {

    var activityIndicatorView = UIActivityIndicatorView()
    var contentVM = StepMaster()
    @IBOutlet weak var navi: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    let userDefaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var selectDate_start = ""
    var selectDate_end = ""
    var now_rank = Int()
    var start = Date()
    var end = Date()
    var is_month = 0
    let now = Date()
    var month_step = 0
    let store = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.tableView?.register(UINib(nibName: "RankUpTableViewCell", bundle: nil), forCellReuseIdentifier: "RankUpTableViewCell")
        self.tableView.register(UINib(nibName: "PointExplanationTableViewCell", bundle: nil), forCellReuseIdentifier: "PointExplanationTableViewCell")

        if userDefaults.object(forKey: "rank") as? Int != nil {
            self.now_rank = (userDefaults.object(forKey: "rank") as? Int)!
        }
        self.navi.title = "現在のランク : " + ApiConfig.RANK_NAME_LIST[self.now_rank]

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        getStepMonthDate()
        tabBarController?.tabBar.isHidden = true
    }

    func viewUploal(){
        self.navi.title = "現在のランク : " + ApiConfig.RANK_NAME_LIST[self.now_rank]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RankUpTableViewCell") as! RankUpTableViewCell
                if self.is_month == 0 {
                    cell.setMonth.text = "今月の歩数"
                } else if self.is_month == 1 {
                    cell.setMonth.text = "先月の歩数"
                }
                cell.period.text = "\(self.selectDate_start) ~ \(self.selectDate_end)"
                cell.monthStep.text = String(self.month_step)
                cell.requestButton.isEnabled = false
                cell.requestButton.backgroundColor =  #colorLiteral(red: 0.007505211513, green: 0.569126904, blue: 0.5776273608, alpha: 1)
                cell.requestButton.setTitle("ランクアップできません", for: .normal)

                if (self.now_rank != 4) {
                    if self.month_step >= Int(ApiConfig.RANK_STEP_LIST[self.now_rank + 1])! {
                        cell.requestButton.backgroundColor =  #colorLiteral(red: 1, green: 0, blue: 0.5997084379, alpha: 1)
                        cell.requestButton.isEnabled = true
                        cell.requestButton.setTitle("ランクアップする", for: .normal)
                    }
                }
                var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                cell.requestButton.addGestureRecognizer(recognizer)

                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PointExplanationTableViewCell") as! PointExplanationTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.pointExplanationImage?.image = UIImage(named: "rank")
                return cell

            }
        }

        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "rankUpCell")
        return cell
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        activityIndicatorView.startAnimating()
        apiRequest()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        return 700
     }

    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.is_month = 0
            self.getStepMonthDate()
        case 1:
            self.is_month = 1
            self.getStepMonthDate()
        default:
            self.is_month = 0
        }
    }
    
    func getStepMonthDate() {

        contentVM.delegate = self
        let calendar = Calendar.current
        if self.is_month == 0 {
            // 月初
            var comps = calendar.dateComponents([.year, .month], from: self.now)
            self.start = calendar.date(from: comps)!
            // 月末
            var add = DateComponents(month: 1, day: -1)
            self.end = calendar.date(byAdding: add, to: self.start)!
        } else if self.is_month == 1 {
            //先月
            var comps = calendar.dateComponents([.year, .month], from: self.now)
            var start_1 = calendar.date(from: comps)
            // 月末
            var add = DateComponents(month: -1)
            self.start = calendar.date(byAdding: add, to: start_1!)!
                       
            var add_1 = DateComponents(month: 0, day: -1)
            self.end = calendar.date(byAdding: add_1, to: start_1!)!
        }
        dateFormatter.dateFormat = "YYYY年MM月dd日"
        self.selectDate_start =  dateFormatter.string(from: self.start)
        self.selectDate_end =  dateFormatter.string(from: self.end)

        contentVM.get(self.start,self.end)
    }
    
    func stepCount(_ count: Double) {
        DispatchQueue.main.async {
            self.month_step = Int(count)
            self.tableView.reloadData()
        }
    }

//    // 今日の歩数を取得するための関数
//    func getMonthStep(completion: @escaping (Double) -> Void) {
//        let calendar = Calendar.current
//        if self.is_month == 0 {
//            // 月初
//            var comps = calendar.dateComponents([.year, .month], from: self.now)
//            self.start = calendar.date(from: comps)!
//            // 月末
//            var add = DateComponents(month: 1, day: -1)
//            self.end = calendar.date(byAdding: add, to: self.start)!
//        //先月
//        } else if self.is_month == 1 {
//            var comps = calendar.dateComponents([.year, .month], from: self.now)
//            var start_1 = calendar.date(from: comps)
//            // 月末
//            var add = DateComponents(month: -1)
//            self.start = calendar.date(byAdding: add, to: start_1!)!
//
//            var add_1 = DateComponents(month: 0, day: -1)
//            self.end = calendar.date(byAdding: add_1, to: start_1!)!
//        }
//        dateFormatter.dateFormat = "YYYY年MM月dd日"
//        self.selectDate_start =  dateFormatter.string(from: self.start)
//        self.selectDate_end =  dateFormatter.string(from: self.end)
//
//
//        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
//        let predicate = HKQuery.predicateForSamples(withStart: self.start as Date, end: self.end as Date, options: .strictStartDate)
//        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .separateBySource) { (query, data, error) in
//            if let sources = data?.sources?.filter({ $0.bundleIdentifier.hasPrefix("com.apple.health") }) {
//                let sourcesPredicate = HKQuery.predicateForObjects(from: Set(sources))
//                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sourcesPredicate])
//                let query = HKStatisticsQuery(quantityType: type,
//                                              quantitySamplePredicate: predicate,
//                                              options: .cumulativeSum)
//                { (query, statistics, error) in
//                    var value: Double = 0
//                    if error != nil {
//                        print("something went wrong")
//                    } else if let quantity = statistics?.sumQuantity() {
//                        value = quantity.doubleValue(for: HKUnit.count())
//                        completion(value)
//                    }
//                }
//                self.store.execute(query)
//            }
//        }
//        store.execute(query)
//    }

    func apiRequest() {
        let parameters = [
            "step" :self.month_step
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.rankUp, parameters: parameters,success: { [self] (response: rankParam) in
            self.activityIndicatorView.stopAnimating()
            self.now_rank = response.now_rank
            self.userDefaults.set(response.now_rank, forKey: "now_rank")
            self.upAlert()
            self.viewUploal()
            self.tableView.reloadData()
            },
            failure: { [self] error in
                //  リクエスト失敗 or キャンセル時
                self.activityIndicatorView.stopAnimating()
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )
    }
    
    func upAlert() {
        // アラート作成
        let rank_name = ApiConfig.RANK_NAME_LIST[self.now_rank]
        let alert = UIAlertController(title: "\(rank_name) ランクにアップしました！", message: "おめでとうございます！！", preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }

}
