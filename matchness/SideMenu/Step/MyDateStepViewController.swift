//
//  MyDateStepViewController.swift
//  matchness
//
//  Created by user on 2019/06/27.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import CoreMotion
import MBCircularProgressBar
import Charts
import HealthKit

class MyDateStepViewController: UIViewController, ChartViewDelegate {


    @IBOutlet weak var toDayButton: UIBarButtonItem!
    @IBOutlet weak var leftbuttonLabel: UIButton!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var schedule: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var progressViewBar: MBCircularProgressBarView!
    @IBOutlet weak var updata_text: UIButton!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var jikanLabel: UILabel!
    @IBOutlet weak var syouhiLabel: UILabel!
    @IBOutlet weak var idouLabel: UILabel!
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var activityIndicatorView = UIActivityIndicatorView()
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    let userDefaults = UserDefaults.standard
    
    var step = 0
    let dateFormatter = DateFormatter()
    let now = Date()
    var day = 0
    var step_1: [Double] = []
    var timer_flag:Bool = true
    // 時間計測用の変数.
    var count : Double = 0
    // タイマー
    var timer : Timer!
    var timer_key = ""
    let formatter = DateComponentsFormatter()
    var weight = Double()
    var height = Double()
    var count_time = 0.0
    let store = HKHealthStore()
    var vibrateFlg:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController!.navigationBar.topItem!.title = ""
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        if day == 0 {
            count_time = 0.0
            day = 0
            self.step_1 = []
            getStepDate()
            getStepTime()
            clertMarker()
        }
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if day == 0 {
//            count_time = 0.0
//            day = 0
//            self.step_1 = []
//            getStepDate()
//            getStepTime()
//            clertMarker()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        barChartView.delegate = self

        if let weight_data = self.userDefaults.object(forKey: "weight") {
            weight = Double(Int((weight_data as! NSString).doubleValue) as! Int)
        }
        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            // 非同期処理などを実行
            Thread.sleep(forTimeInterval: 5)
            // 非同期処理などが終了したらメインスレッドでアニメーション終了
            DispatchQueue.main.async {
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
            }
        }
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
//        getStepDate()
//        getStepTime()

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MyDateStepViewController.onUpdate(timer:)), userInfo: nil, repeats: true)
        self.playLabel.text = "STEP"
        self.navigationItem.title = "歩数計"
        tabBarController?.tabBar.isHidden = false

        toDayButton.title = "更新"
        toDayButton.tintColor = .popoPink
        
        jikanLabel.text = "時間"
        syouhiLabel.text = "消費カロリー"
        idouLabel.text = "移動距離"
    }

    func getStepDate() {
        rightButton.isEnabled = false
        leftButton.isEnabled = false

        getDayStep { (result) in
            DispatchQueue.main.async {
                var Step_bar = 0.0
                if Int(result) > 10000 {
                    self.stepCountLabel.font = self.stepCountLabel.font.withSize(55)
                    Step_bar = 10000.0
                } else {
                    Step_bar = result
                }
                //歩数
                self.stepCountLabel.text = String(Int(result))
                self.progressViewBar.value = (CGFloat(Double(Step_bar) / 10000)*100)
//                self.progressViewBar.value = (CGFloat(Double(10000.0) / 10000)*100)
                //距離
                if var height_1 = self.userDefaults.object(forKey: "height"){
//                    self.height = height_1 as! Double
                    self.height = Double(Int((height_1 as! NSString).doubleValue))
                } else {
                    self.height = 150
                }

                var stride = Double(Int(self.height)) * 0.45
                var distance = Int(result) * Int(stride)
                var distance_data = (Double(distance) / 100000)
                var distance_para = round(distance_data*100)/100
                self.distance.text = "\(distance_para)km"

                //カロリー
                if let weight_1 = self.userDefaults.object(forKey: "weight") {
                    self.weight = Double(Int((weight_1 as! NSString).doubleValue))
                } else {
                    self.weight = 40
                }

                self.count = Double(result) / 1.7
                var hour = self.count / 3600
                var kacl = 1.05 * (3.3 * hour) * self.weight
                self.kcalLabel.text = "\(floor(kacl*10)/10)kcal"

                //時間
                self.formatter.unitsStyle = .positional
                self.formatter.allowedUnits = [.hour, .minute, .second]
                self.timeLabel.text = self.formatter.string(from: self.count)

                self.activityIndicatorView.stopAnimating()
            }
        }
    }

    
    // 今日の歩数を取得するための関数
    func getDayStep(completion: @escaping (Double) -> Void) {
        let from = Date(timeInterval: TimeInterval(-60*60*24*day), since: now)

        dateFormatter.dateFormat = "MM月dd日"
        let selectDate =  dateFormatter.string(from: from)
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "E", options: 0, locale: Locale.current)
        self.schedule.text = "\(selectDate + " " + dateFormatter.string(from: from))"
        
        var key = dateFormatter.string(from: now)
        self.timer_key = selectDate + "step_time"

        if day == 0 {
            leftbuttonLabel.isHidden = true

            toDayButton.title = "更新"
            toDayButton.tintColor = .popoPink

        } else {
            leftbuttonLabel.isHidden = false
            toDayButton.title = "本日へ"
            toDayButton.tintColor = .popoTextColor
        }

        if UserDefaults.standard.object(forKey: timer_key) != nil {
            self.count = userDefaults.object(forKey: timer_key) as! Double
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            let str = formatter.string(from: self.count)
            // ラベルに表示
            timeLabel.text = str
        } else {
            self.count = 0
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

        let query = HKStatisticsQuery(quantityType: type,quantitySamplePredicate: predicate,options: .cumulativeSum) { (query, statistics, error) in
              var value: Double = 0
              if error != nil {
                  print("something went wrong")
              } else if let quantity = statistics?.sumQuantity() {
                  value = quantity.doubleValue(for: HKUnit.count())
                  completion(value)
              }
        }
        store.execute(query)
    }

    
    func getStepTime() {
        var dataEntries: [BarChartDataEntry] = []
        self.barChartView.animate(yAxisDuration: 0.1)
        self.barChartView.rightAxis.axisMinimum = 0
        self.barChartView.leftAxis.axisMinimum = 0
        // self.barChartView.leftAxis.axisMaximum = 1000.0
        //右軸（値）の非表示
        self.barChartView.rightAxis.drawLabelsEnabled = false
        //self.barChartView.leftAxis.enabled  = true  //左軸（値）の表示
        //タップ
        self.barChartView.highlightPerTapEnabled = true

        self.barChartView.xAxis.drawGridLinesEnabled = false
        self.barChartView.xAxis.labelPosition = .bottom
        self.barChartView.xAxis.labelCount = 12
        self.barChartView.chartDescription?.enabled = false
        self.barChartView.legend.enabled = false
        self.barChartView.doubleTapToZoomEnabled = false
        self.barChartView.pinchZoomEnabled = false
        self.barChartView.doubleTapToZoomEnabled = false
        self.barChartView.scaleXEnabled = false
        self.barChartView.scaleYEnabled = false
        self.barChartView.dragEnabled = false
        self.barChartView.drawGridBackgroundEnabled = true

        
        
        let from = Date(timeInterval: TimeInterval(-60*60*24*self.day), since: self.now)
        var component = NSCalendar.current.dateComponents([.year, .month, .day], from: from)
        component.hour = 0
        component.minute = 0
        component.second = 0
        let startDate:NSDate = NSCalendar.current.date(from:component)! as NSDate
        //XX月XX日23時59分59秒に設定したものをendにいれる
        component.hour = 23
        component.minute = 59
        component.second = 59
        let endDate:NSDate = NSCalendar.current.date(from:component)! as NSDate
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate as Date,
            end: endDate as Date,
          options: [.strictStartDate, .strictEndDate]
        )

        var interval = DateComponents()
        interval.hour = 1
        let query = HKStatisticsCollectionQuery(
          quantityType: HKSampleType.quantityType(forIdentifier: .stepCount)!,
          quantitySamplePredicate: predicate,
          options: .cumulativeSum,
          anchorDate: startDate as Date,
          intervalComponents: interval
        )

        query.initialResultsHandler = { query, results, error in
          guard let results = results else {
            return
          }

          results.enumerateStatistics(
            from: startDate as Date,
            to: endDate as Date,
            with: { (result, stop) in
              let totalStepForADay = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
//                print(totalStepForADay)
                self.count_time += 1
                let dataEntry = BarChartDataEntry(x: Double(self.count_time), y: floor(totalStepForADay))
                dataEntries.append(dataEntry)
            }
          )

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [.popoTextGreen]

            self.barChartView.data = BarChartData(dataSet: chartDataSet)

            let dispatchTime = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter( deadline: dispatchTime ) {
                self.rightButton.isEnabled = true
                self.leftButton.isEnabled = true
            }
        }
        store.execute(query)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let pos = NSInteger(entry.x)
        let pos1 = NSInteger(entry.y)
        self.showMarkerView(value: "\(pos1)")
    }
    
    func showMarkerView(value:String){
        //使用气泡状的标签
        let marker = BalloonMarker(
            color: .white,
            font: .systemFont(ofSize: 12),
            textColor: .popoTextGreen,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
        )
        marker.chartView = self.barChartView
        marker.minimumSize = CGSize(width: 40, height: 40)
        marker.setLabel("\(value)\nstep")
        self.barChartView.marker = marker
    }
    
    @IBAction func leftButton(_ sender: Any) {
        if (day > 0) {
            count_time = 0.0
            day = day - 1
            self.step_1 = []
            getStepDate()
            getStepTime()
            clertMarker()
        }
    }

    @IBAction func toToday(_ sender: Any) {
        count_time = 0.0
        day = 0
        self.step_1 = []
        getStepDate()
        getStepTime()
        clertMarker()

    }
    
    @IBAction func rightButton(_ sender: Any) {
        day = day + 1
        count_time = 0.0
        self.step_1 = []
        getStepDate()
        getStepTime()
        clertMarker()
    }

    
    func clertMarker() {
        let marker = BalloonMarker(
            color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0),
            font: .systemFont(ofSize: 0),
            textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0),
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        )
        self.barChartView.marker = marker
    }

   // TimerのtimeIntervalで指定された秒数毎に呼び出されるメソッド
   @objc func onUpdate(timer : Timer){
       if (day == 0) {
           // カウントの値1増加
           count += 1
            //カロリー
           if let weight_1 = self.userDefaults.object(forKey: "weight") {
               self.weight = Double(Int((weight_1 as! NSString).doubleValue))
           } else {
               self.weight = 40
           }
           self.activityIndicatorView.stopAnimating()
           formatter.unitsStyle = .positional
           formatter.allowedUnits = [.hour, .minute, .second]
           let str = formatter.string(from: count)
           var hour = count / 3600
           var kacl = 1.05 * 3 * hour * Double(self.weight)
           kcalLabel.text = "\(floor(kacl*10)/10)kcal"

        
        // ラベルに表示
           timeLabel.text = str
           UserDefaults.standard.set(count, forKey: self.timer_key)
       }
   }
   // カウントを停止するメソッド
   func stopBtnTap() {
       timer.invalidate()
       self.timer_flag = false
   }
   // カウントの停止を解除するメソッド
   func startBtnTap() {
       // 新たにタイマーを作る
       timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MyDateStepViewController.onUpdate(timer:)), userInfo: nil, repeats: true)
       self.timer_flag = true
   }

}


extension Date {
    var weekday: String {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: self)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        return formatter.weekdaySymbols[weekday]
    }
}


