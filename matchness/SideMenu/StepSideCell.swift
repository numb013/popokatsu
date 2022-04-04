//
//  StepSideCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/10/01.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import CoreMotion
import MBCircularProgressBar
//import Charts
import HealthKit

class StepSideCell: UITableViewCell {
    var contentVM = StepMaster()
    @IBOutlet weak var progressViewBar: MBCircularProgressBarView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var schedule: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    
    let store = HKHealthStore()
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    let userDefaults = UserDefaults.standard

//    var activityIndicatorView = UIActivityIndicatorView()
    
    var step = 0
    let dateFormatter = DateFormatter()
    let now = Date()
    var day = 0
    var counter = 0.0
    var step_1: [Double] = []
    var timer_flag:Bool = true
    // 時間計測用の変数.
    var count : Double = 0
    var steps = 0.0
    // タイマー
    var timer : Timer!
    var timer_key = ""
    let formatter = DateComponentsFormatter()
    // 一時停止の際の時間を格納する
    var pauseTime:Float = 0
    var weight = Double()
    var height = Double()
    var count_time = 0.0
    var vibrateFlg:Bool = false
    


    override func awakeFromNib() {
        super.awakeFromNib()
        if day == 0 {
            count_time = 0.0
            day = 0
            self.step_1 = []
//            getStepDate()


//            contentVM.delegate = self
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"


            contentVM.get(
                Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 0, second: 0, of: Date())!,
                now
            )
            DispatchQueue.main.async { [self] in
                print("歩数歩数歩数歩数歩数歩数歩数", contentVM.count)
                var result = contentVM.count
                var Step_bar = 0.0
                if Int(result) > 10000 {
                    self.stepCountLabel.font = self.stepCountLabel.font.withSize(44)
                    Step_bar = 10000.0
                } else {
                    Step_bar = result
                }
                //歩数
                self.stepCountLabel.text = String(Int(result))
                self.progressViewBar.value = (CGFloat(Double(Step_bar) / 10000)*100)
                
                //距離
                if var height_1 = self.userDefaults.object(forKey: "height"){
                    self.height = Double(Int((height_1 as! NSString).doubleValue))
                } else {
                    self.height = 150
                }

                // 時間
                var stride = Double(Int(self.height)) * 0.45
                var distance = Int(result) * Int(stride)
                var distance_data = (Double(distance) / 100000)
                var distance_para = round(distance_data*100)/100
                if Int(distance_para) > 1000 {
                    self.distance.text = "\(distance_para)"
                } else {
                    self.distance.text = "\(distance_para)km"
                }
                
                //カロリー
                if let weight_1 = self.userDefaults.object(forKey: "weight") {
                    self.weight = Double(Int((weight_1 as! NSString).doubleValue))
                } else {
                    self.weight = 40
                }

                self.count = Double(result) / 1.7
                var hour = self.count / 3600
                var kacl = 1.05 * (3.3 * hour) * self.weight
                var kaclText = floor(kacl*10)/10
                if Int(kaclText) > 1000 {
                    self.kcalLabel.text = "\(kaclText)"
                } else {
                    self.kcalLabel.text = "\(kaclText)kcal"
                }

                //時間
                self.formatter.unitsStyle = .positional
                self.formatter.allowedUnits = [.hour, .minute, .second]
                self.timeLabel.text = self.formatter.string(from: self.count)

            }
        }

        if let weight_data = self.userDefaults.object(forKey: "weight") {
            weight = Double(Int((weight_data as! NSString).doubleValue) as! Int)
        }

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(StepSideCell.onUpdate(timer:)), userInfo: nil, repeats: true)
        self.playLabel.text = "STEP"
    }


//    func getStepDate() {
//        getDayStep { (result) in
//            DispatchQueue.main.async {
//                var Step_bar = 0.0
//                if Int(result) > 10000 {
//                    self.stepCountLabel.font = self.stepCountLabel.font.withSize(55)
//                    Step_bar = 10000.0
//                } else {
//                    Step_bar = result
//                }
//                //歩数
//                self.stepCountLabel.text = String(Int(result))
//                self.progressViewBar.value = (CGFloat(Double(Step_bar) / 10000)*100)
//
//                //距離
//                if var height_1 = self.userDefaults.object(forKey: "height"){
//                    self.height = Double(Int((height_1 as! NSString).doubleValue))
//                } else {
//                    self.height = 150
//                }
//
//                // 時間
//                var stride = Double(Int(self.height)) * 0.45
//                var distance = Int(result) * Int(stride)
//                var distance_data = (Double(distance) / 100000)
//                var distance_para = round(distance_data*100)/100
//                self.distance.text = "\(distance_para)km"
//
//                //カロリー
//                if let weight_1 = self.userDefaults.object(forKey: "weight") {
//                    self.weight = Double(Int((weight_1 as! NSString).doubleValue))
//                } else {
//                    self.weight = 40
//                }
//
//                self.count = Double(result) / 1.7
//                var hour = self.count / 3600
//                var kacl = 1.05 * (3.3 * hour) * self.weight
//                self.kcalLabel.text = "\(floor(kacl*10)/10)kcal"
//
//                //時間
//                self.formatter.unitsStyle = .positional
//                self.formatter.allowedUnits = [.hour, .minute, .second]
//                self.timeLabel.text = self.formatter.string(from: self.count)
//
////                self.activityIndicatorView.stopAnimating()
//            }
//        }
//    }

//
//    // 今日の歩数を取得するための関数
//    func getDayStep(completion: @escaping (Double) -> Void) {
//        let from = Date(timeInterval: TimeInterval(-60*60*24*day), since: now)
//
//        dateFormatter.dateFormat = "MM月dd日"
//        let selectDate =  dateFormatter.string(from: from)
//        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "E", options: 0, locale: Locale.current)
//        self.schedule.text = "\(selectDate + " " + dateFormatter.string(from: from))"
//
//
//        var component = NSCalendar.current.dateComponents([.year, .month, .day], from: from)
//        component.hour = 0
//        component.minute = 0
//        component.second = 0
//        let start:NSDate = NSCalendar.current.date(from:component)! as NSDate
//        //XX月XX日23時59分59秒に設定したものをendにいれる
//        component.hour = 23
//        component.minute = 59
//        component.second = 59
//        let end:NSDate = NSCalendar.current.date(from:component)! as NSDate
//        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
//        let predicate = HKQuery.predicateForSamples(withStart: start as Date, end: end as Date, options: .strictStartDate)
//
//        let query = HKStatisticsQuery(quantityType: type,quantitySamplePredicate: predicate,options: .cumulativeSum) { (query, statistics, error) in
//              var value: Double = 0
//              if error != nil {
//                  print("something went wrong")
//              } else if let quantity = statistics?.sumQuantity() {
//                  value = quantity.doubleValue(for: HKUnit.count())
//                  completion(value)
//              }
//        }
//        store.execute(query)
//    }

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
}


