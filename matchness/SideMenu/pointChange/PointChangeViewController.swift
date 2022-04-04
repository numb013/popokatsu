//
//  PointChangeViewController.swift
//  matchness
//
//  Created by user on 2019/07/18.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import CoreMotion
import HealthKit
import StoreKit
import GoogleMobileAds

class PointChangeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate{

    let userDefaults = UserDefaults.standard
    private var interstitial: GADInterstitialAd?

    var contentVM = StepMaster()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPoint: UILabel!
    @IBOutlet weak var todayStep: UILabel!
    @IBOutlet weak var yesterdayStep: UILabel!
    @IBOutlet weak var todayPoint: UILabel!
    @IBOutlet weak var yesterdayPoint: UILabel!
    @IBOutlet weak var t_button: UIButton!
    @IBOutlet weak var y_button: UIButton!
    let store = HKHealthStore()
    
    var t_Point = 0
    var y_Point = 0
    var tapStatus = 1
    var todayPointChenge = 0
    var yesterdayPointChenge = 0

    let dateFormatter = DateFormatter()
    let now = Date()
    var day = 0
    var from = Date()
    var yestarday = Date()
    var step_data = [0,0]
    var text_1 = ""
    var text_2 = ""
    
    private var presenter: PointChangeInput!
    func inject(presenter: PointChangeInput) {
        // このinputがpresenterのこと
        self.presenter = presenter
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.register(UINib(nibName: "PointChangeCellTableViewCell", bundle: nil), forCellReuseIdentifier: "PointChangeCellTableViewCell")
        self.tableView.register(UINib(nibName: "PointExplanationTableViewCell", bundle: nil), forCellReuseIdentifier: "PointExplanationTableViewCell")
        self.tableView?.register(UINib(nibName: "UserDetailInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailInfoTableViewCell")
        getStepDate1()
        getStepDate2()

        loadInterstitial()
        
        let presenter = PointChangePresenter(view: self)
        inject(presenter: presenter)
        presenter.apiPointSelect()
    }
    
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3233612928012980/2786126078", request: GADRequest()) { [weak self] (ad, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self?.interstitial = ad
            print("高恋く")
            print(self?.interstitial)
            self?.interstitial?.present(fromRootViewController: self!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.topItem!.title = ""
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "ポイント交換"
    }
    
    func pointView() {
        var tunagi = " / "
        var stepData = presenter.data[0]
        self.userPoint.text = String(stepData.point!)

        self.userPoint.font = UIFont.systemFont(ofSize: 3, weight: .bold)

        self.userDefaults.set(stepData.point, forKey: "point")
        let point_point = self.userDefaults.object(forKey: "point") as! Int
        self.todayStep.text = String(stepData.todayPointChenge!) + tunagi + String(self.step_data[0])
        self.yesterdayStep.text = String(stepData.yesterdayPointChenge!) + tunagi + String(self.step_data[1])
        self.t_Point = self.step_data[0] - stepData.todayPointChenge!
        self.y_Point = self.step_data[1] - stepData.yesterdayPointChenge!
        self.todayPoint.text = String(Int(floor(Double(self.t_Point) * 0.01)))
        self.yesterdayPoint.text = String(Int(floor(Double(self.y_Point) * 0.01)))
        t_button.isEnabled = self.t_Point <= 100 ? false : true // ボタン無効
        self.todayPoint.textColor =  self.t_Point <= 100 ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        y_button.isEnabled = self.y_Point <= 100 ? false : true // ボタン無効
        self.yesterdayPoint.textColor =  self.y_Point <= 100 ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if presenter.data.count == 0 {
            return cell!
        }
        var tunagi = " / "
        var stepData = presenter.data[0]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PointChangeCellTableViewCell") as! PointChangeCellTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            if stepData != nil {
                print("OPOPOPOPOPOPOPOP", stepData.point)
                cell.userPoint.text = String(stepData.point!)
                let point_point = self.userDefaults.object(forKey: "point") as! Int
                cell.todayStep.text = String(stepData.todayPointChenge!) + tunagi + String(self.step_data[0])
                cell.yesterdayStep.text = String(stepData.yesterdayPointChenge!) + tunagi + String(self.step_data[1])
                self.t_Point = self.step_data[0] - stepData.todayPointChenge!
                self.y_Point = self.step_data[1] - stepData.yesterdayPointChenge!
                cell.todayPoint.text = String(Int(floor(Double(self.t_Point) * 0.01)))
                cell.yesterdayPoint.text = String(Int(floor(Double(self.y_Point) * 0.01)))
                cell.todayPoint.textColor =  self.t_Point <= 100 ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
                cell.yesterdayPoint.textColor =  self.y_Point <= 100 ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
                cell.t_button.isUserInteractionEnabled = true
                var recognizer1 = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                recognizer1.targetString = "1"
                cell.t_button.addGestureRecognizer(recognizer1)

                cell.y_button.isUserInteractionEnabled = true
                var recognizer2 = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                recognizer2.targetString = "2"
                cell.y_button.addGestureRecognizer(recognizer2)
                
                cell.payButton.isUserInteractionEnabled = true
                var recognizer4 = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
                recognizer4.targetString = "4"
                cell.payButton.addGestureRecognizer(recognizer4)
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "userDetailInfo")
            cell.textLabel!.numberOfLines = 0
            cell.backgroundColor =  UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel!.font = UIFont.systemFont(ofSize: 14)
            cell.textLabel!.textColor = #colorLiteral(red: 0.4321289659, green: 0.4295647442, blue: 0.4341031313, alpha: 1)
            cell.textLabel!.text = "１００歩につき１ポイント交換ができます。\n\nもし歩数が０の場合は少し歩いてから再度確認してみて下さい、それでも０のまま動かない場合は下記の設定を行なってみて下さい。\n\niPhoneの設定アプリを起動して、「プライバシー」→「ヘルスケア」→「POPO-KATSU」を選択して、「全てのカテゴリーをオン」にしてください。"
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PointExplanationTableViewCell") as! PointExplanationTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            if self.userDefaults.object(forKey: "sex")! as! Int == 1 {
                cell.pointExplanationImage?.image = UIImage(named: "pay_girl")
            } else {
                cell.pointExplanationImage?.image = UIImage(named: "pay_boy")
            }
            return cell
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 395
        } else if indexPath.row == 1 {
            tableView.estimatedRowHeight = 200 //セルの高さ
            return UITableView.automaticDimension //自動設定
        }
        return 950
     }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var number = sender.targetString!

        if self.tapStatus == 1 {
            self.tapStatus = 2
            if number == "1" {
                if self.t_Point >= 100 {
                    requestUpdatePoint(0, self.t_Point)
                } else {
                   self.tapStatus = 1
                   let alert = UIAlertController(title: "ポイント交換できません", message: "ポイント交換が０の為、交換できません。\n１００歩につき１ポイント交換ができます。", preferredStyle: .alert)
                    let backView = alert.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.present(alert, animated: true, completion: {
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                           alert.dismiss(animated: true, completion: nil)
                       })
                   })
               }
            }
            
            if number == "2" {
                if self.y_Point >= 100 {
                    requestUpdatePoint(1, self.y_Point)
                } else {
                    self.tapStatus = 1
                   let alert = UIAlertController(title: "ポイント交換できません", message: "ポイント交換が０の為、交換できません。\n１００歩につき１ポイント交換ができます。", preferredStyle: .alert)
                    let backView = alert.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    self.present(alert, animated: true, completion: {
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                           alert.dismiss(animated: true, completion: nil)
                       })
                   })
               }
            }
        }
        if number == "4" {
            performSegue(withIdentifier: "toPaymentPoint", sender: self)
        }
    }

    func getStepDate1() {
        self.day = 1
        getDayStep { (result) in
            DispatchQueue.main.async {
                self.step_data[0] = Int(result)
                 self.text_1 = "\(self.todayPointChenge) / \(self.step_data[0])"
                 self.tableView.reloadData()
            }
        }
    }
    func getStepDate2() {
        self.day = 2
        getDayStep { (result) in
            DispatchQueue.main.async {
                self.step_data[1] = Int(result)
                self.text_2 = "\(self.yesterdayPointChenge) / \(self.step_data[1])"
                self.tableView.reloadData()
            }
        }
    }
    
    // 今日の歩数を取得するための関数
    func getDayStep(completion: @escaping (Double) -> Void) {
        if self.day == 1 {
            from = Date(timeInterval: TimeInterval(-60*60*24*0), since: now)
        }
        if self.day == 2 {
            from = Date(timeIntervalSinceNow: -60 * 60 * 24)
            self.yestarday = from
        }
        if self.day == 3 {
            from = Date(timeInterval: -60 * 60 * 24, since: self.yestarday)
        }

        var component = NSCalendar.current.dateComponents([.year, .month, .day], from: from)
        component.hour = 0
        component.minute = 0
        component.second = 0
        let start:NSDate = NSCalendar.current.date(from:component)! as NSDate
        //XX月XX日23時59分59秒に設定したものをendにいれる
        component.hour = 23
        component.minute = 59
        component.second = 59
        let end:NSDate = NSCalendar.current.date(from:component)! as NSDate
        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        
        let predicate = HKQuery.predicateForSamples(withStart: start as Date, end: end as Date, options: .strictStartDate)
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

    func requestUpdatePoint(_ day:Int, _ point:Int) {
        presenter.apiPointGet(day, point)
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func paymentButton(_ sender: Any) {
        performSegue(withIdentifier: "toPaymentPoint", sender: self)
    }
}

extension Array {
    func canAccess(index: Int) -> Bool {
        return self.count-1 >= index
    }
}

extension PointChangeViewController: PointChangeOutput {
    func update() {
        self.tapStatus = 1
        tableView.reloadData()
    }
    
    func error() {
        //
    }
}
