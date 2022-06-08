//
//  WishViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/05/04.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit
import HealthKit
import Alamofire
import SwiftyJSON

struct wishParam: Codable {
    let next_week_step: String
    let this_clear: Int
    let this_week_step: String
    let last_clear: Int
    let last_week_step: String
}

class WishViewController: UIViewController,UITextFieldDelegate, StepMasterDelegate {

    let calendar = Calendar.current
    let formatter = DateFormatter()
    var contentVM = StepMaster()
    @IBOutlet weak var this_week_text: UILabel!
    @IBOutlet weak var next_week_text: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var remainingText: UILabel!
    @IBOutlet weak var notReallyText: UILabel!
    @IBOutlet weak var nowStep: UILabel!
    @IBOutlet weak var achievementButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var wishStep: UITextField!
    var activityIndicatorView = UIActivityIndicatorView()
    private var requestAlamofire: Alamofire.Request?
    let dateFormatter = DateFormatter()
    let store = HKHealthStore()
    var selectDate_start = ""
    var selectDate_end = ""
    var next_selectDate_start = ""
    var next_selectDate_end = ""
    var start = Date()
    var end = Date()
    var week_step = 0
    var is_week = 0
    let now = Date()
    var next_step = ""
    var this_end = Date()
    var this_step = "0"
    var this_clear: Int = 0
    var last_step = "0"
    var last_clear: Int = 0
    var validate = 0
    var error_message = ""
    var clear_point = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        getStepWeekDate()
        apiRequest(status: 1)
        wishStep.delegate = self
        wishStep.placeholder = "※300以上設定して下さい"
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func viewUpload() {
        wishStep.text = self.next_step
        achievementButton.isEnabled = false
        achievementButton.backgroundColor = .popoGreen
        achievementButton.setTitle("達成してません", for: .normal)
        
        if self.is_week == 0 {
            if Int(self.this_step) != 0 {
                this_week_text.text = self.selectDate_start + "~" + self.selectDate_end
                var nokori = Int(self.this_step)! - self.week_step
                if self.this_clear == 1 {
                    achievementButton.backgroundColor = .popoPinkOff
                    achievementButton.isEnabled = false
                    achievementButton.setTitle("達成済", for: .normal)
                    nokori = 0
                } else if (nokori <= 0) {
                    achievementButton.backgroundColor = .popoPink
                    achievementButton.isEnabled = true
                    achievementButton.setTitle("ポイントを受け取る", for: .normal)
                    nokori = 0
                }
                remainingText.text = "今週の目標 " + self.this_step + " step"
                notReallyText.text = "目標達成まで残り " + String(nokori) + " step"
                nowStep.text = String(self.week_step) + " / " + self.this_step

            } else {

                achievementButton.backgroundColor = .popoTextGreen
                achievementButton.isEnabled = false
                achievementButton.setTitle("目標未設定", for: .normal)

                this_week_text.text = ""
                remainingText.text = "今週の目標は未設定です"
                notReallyText.text = "来週の目標を設定してください。"
                nowStep.text = "-"
            }
            
        } else if self.is_week == 1 {
            if Int(self.last_step) != 0 {
                this_week_text.text = self.selectDate_start + "~" + self.selectDate_end
                var nokori = Int(self.last_step)! - self.week_step
                if self.last_clear == 1 {
                    achievementButton.backgroundColor = .popoPinkOff
                    achievementButton.isEnabled = false
                    achievementButton.setTitle("達成済", for: .normal)
                    nokori = 0
                } else if (nokori <= 0) {
                    achievementButton.backgroundColor = .popoPink
                    achievementButton.isEnabled = true
                    achievementButton.setTitle("ポイントを受け取る", for: .normal)
                    nokori = 0
                }
                remainingText.text = "先週の目標 " + self.last_step + " step"
                notReallyText.text = "目標達成まで残り " + String(nokori) + " step"
                nowStep.text = String(self.week_step) + " / " + self.last_step
            } else {
                achievementButton.backgroundColor = .popoTextGreen
                achievementButton.isEnabled = false
                achievementButton.setTitle("目標未設定", for: .normal)

                this_week_text.text = ""
                remainingText.text = "先週の目標は未設定です"
                notReallyText.text = "来週の目標を設定してください。"
                nowStep.text = "-"
            }
        }
        
        next_week_text.text = self.next_selectDate_start + "~" + self.next_selectDate_end
        self.wishStep.keyboardType = UIKeyboardType.numberPad
    }
    
    func getStepWeekDate() {

        contentVM.delegate = self
        if self.is_week == 0 {
            //今週
            self.start = Calendar.current.startOfWeek(for: now)
            self.this_end = Calendar.current.endOfWeek(for: now)
            self.end = self.this_end
            var end_1 = calendar.date(byAdding: .day, value: -1, to: Calendar.current.endOfWeek(for: now))!
            //日付の文字列作成
            var week_st = formatter.string(from: self.start as Date)
             self.selectDate_start = "\(dateFormatter.string(from: self.start) + "(" + week_st + ")")"
            var week_end = formatter.string(from: end_1 as Date)
            self.selectDate_end = "\(dateFormatter.string(from: end_1) + "(" + week_end + ")")"
            
        } else if self.is_week == 1 {
            //先週
            self.start = Calendar.current.previousWeek(for: now)
            self.end = Calendar.current.startOfWeek(for: now)
            let lastWeek_1 = Calendar.current.startOfWeek(for: now)
            var end_1 = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: lastWeek_1))!
            //日付の文字列作成
            var week_st = formatter.string(from: self.start as Date)
             self.selectDate_start = "\(dateFormatter.string(from: self.start) + "(" + week_st + ")")"
            var week_end = formatter.string(from: end_1 as Date)
            self.selectDate_end = "\(dateFormatter.string(from: end_1) + "(" + week_end + ")")"
        
        }
        contentVM.get(self.start,self.end)

        dateFormatter.dateFormat = "MM月dd日"
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEEE", options: 0, locale:  Locale.current)

        //来週日付の文字列作成
        var next_start = Calendar.current.nextWeek(for: now)
        var nx_week_st = formatter.string(from: next_start as Date)
        self.next_selectDate_start = "\(dateFormatter.string(from: next_start) + "(" + nx_week_st + ")")"
        
        var next_end = calendar.date(byAdding: .day, value: 6, to: calendar.startOfDay(for: Calendar.current.nextWeek(for: now)))!
        var nx_week_end = formatter.string(from: next_end as Date)
        self.next_selectDate_end = "\(dateFormatter.string(from: next_end) + "(" + nx_week_end + ")")"
    }

    func stepCount(_ count: Double) {
        self.week_step = Int(count)
        print("WWW歩数歩数歩数歩歩数歩数WWWWW", self.week_step)
        DispatchQueue.main.async {
            self.viewUpload()
        }
    }
//    // 今日の歩数を取得するための関数
//    func getWeekStep(completion: @escaping (Double) -> Void) {
//        let calendar = Calendar.current
//        dateFormatter.dateFormat = "MM月dd日"
//        let formatter = DateFormatter()
//        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
//        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEEE", options: 0, locale:  Locale.current)
//
//        if self.is_week == 0 {
//
//            self.this_end = Calendar.current.endOfWeek(for: now)
//            self.start = Calendar.current.startOfWeek(for: now)
//            self.end = self.this_end
//            var end_1 = calendar.date(byAdding: .day, value: -1, to: Calendar.current.endOfWeek(for: now))!
//            //日付の文字列作成
//            var week_st = formatter.string(from: self.start as Date)
//             self.selectDate_start = "\(dateFormatter.string(from: self.start) + "(" + week_st + ")")"
//            var week_end = formatter.string(from: end_1 as Date)
//            self.selectDate_end = "\(dateFormatter.string(from: end_1) + "(" + week_end + ")")"
//
//
//            print("AAAAAAAA", is_week, self.start, self.end)
//            //AAAAAAAA 0 2022-02-05 15:00:00 +0000 2022-02-12 15:00:00 +0000
//            //先月
//        } else if self.is_week == 1 {
//            // 先週始め
//
//            self.start = Calendar.current.previousWeek(for: now)
//
//            // 週終
//            var calendar = Calendar.current
//            let lastWeek_1 = Calendar.current.startOfWeek(for: now)
//            self.end = Calendar.current.startOfWeek(for: now)
//            var end_1 = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: lastWeek_1))!
//
//            //日付の文字列作成
//            var week_st = formatter.string(from: self.start as Date)
//             self.selectDate_start = "\(dateFormatter.string(from: self.start) + "(" + week_st + ")")"
//            var week_end = formatter.string(from: end_1 as Date)
//            self.selectDate_end = "\(dateFormatter.string(from: end_1) + "(" + week_end + ")")"
//
//
//
//            print("BBBBBBBB",is_week, self.start, self.end)
//            //BBBBBBBB 1 2022-01-29 15:00:00 +0000 2022-02-05 15:00:00 +0000
//        }
//
//        //来週日付の文字列作成
//        var next_start = Calendar.current.nextWeek(for: now)
//        var nx_week_st = formatter.string(from: next_start as Date)
//        self.next_selectDate_start = "\(dateFormatter.string(from: next_start) + "(" + nx_week_st + ")")"
//
//        var next_end = calendar.date(byAdding: .day, value: 6, to: calendar.startOfDay(for: Calendar.current.nextWeek(for: now)))!
//        var nx_week_end = formatter.string(from: next_end as Date)
//        self.next_selectDate_end = "\(dateFormatter.string(from: next_end) + "(" + nx_week_end + ")")"

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
//
//                        value = quantity.doubleValue(for: HKUnit.count())
//                        completion(value)
//                    }
//                }
//                self.store.execute(query)
//            }
//        }
//        store.execute(query)
//    }

    func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setButton.isEnabled = false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.next_step = textField.text!
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.next_step = textField.text!
        textField.resignFirstResponder()
        return
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setButton.isEnabled = true
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        self.next_step = textField.text!
        textField.resignFirstResponder()
        setButton.isEnabled = true
        return true
    }

    @IBAction func setButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        apiRequest(status: 2)
    }

    @IBAction func achievementButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        apiRequest(status: 3)
    }

    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.is_week = 0
            self.getStepWeekDate()
        case 1:
            self.is_week = 1
            self.getStepWeekDate()
        default:
            self.is_week = 0
        }
    }
    
    func validator(){
        if self.validate == 1 {
            self.error_message = "目標設定を入力力してください。"
        } else {
            self.error_message = "目標設定は300step以上設定してください。"
        }
        // アラート作成
        let alert = UIAlertController(title: "入力して下さい", message: self.error_message, preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                alert.dismiss(animated: true, completion: nil)
                self.validate = 0
            })
        })
        self.activityIndicatorView.stopAnimating()
    }

    func apiRequest(status:Int) {
        //パラメーター

        var query: Dictionary<String,String> = Dictionary<String,String>();
        var setAPIModule : APIModule = POPOAPI.base.selectWish
        if status == 2 {
            if (self.next_step == "") {
                self.validate = 1
                validator()
            } else if (Int(self.next_step)! < 100) {
                self.validate = 2
                validator()
            }

            setAPIModule = POPOAPI.base.setWish
            dateFormatter.dateFormat = "YYYY-MM-dd"
            var nextWeek =  dateFormatter.string(from: Calendar.current.nextWeek(for: now))
            query["wish_step"] = self.next_step
            query["wish_date"] = nextWeek
        } else if status == 3 {
            setAPIModule = POPOAPI.base.requestWish
            query["wish_step"] = String(self.week_step)
            if self.is_week == 0 {
                dateFormatter.dateFormat = "YYYY-MM-dd"
                var wish_date =  dateFormatter.string(from: Calendar.current.startOfWeek(for: now))
                query["wish_date"] = wish_date
                self.clear_point =  String(Int(floor(Double(Int(self.this_step)!) / 300)))
                query["clear_point"] = self.clear_point
            } else if self.is_week == 1 {
                self.dateFormatter.dateFormat = "YYYY-MM-dd"
                var wish_date =  dateFormatter.string(from: Calendar.current.previousWeek(for: now))
                query["wish_date"] = wish_date
                self.clear_point = String(Int(floor(Double(Int(self.last_step)!) / 300)))
                query["clear_point"] = self.clear_point
            }
        }
        
        
        API.requestHttp(setAPIModule, parameters: query,success: { [self] (response: wishParam) in
            self.activityIndicatorView.stopAnimating()
            if (status == 1 || status == 3) {
                self.next_step = response.next_week_step
                self.this_clear = response.this_clear
                self.this_step = response.this_week_step
                self.last_clear = response.last_clear
                self.last_step = response.last_week_step
                if status == 3 {
                    self.clearAlert()
                }
                self.viewUpload()
            } else if status == 2 {
                self.setAlert()
            }
            
            },
            failure: { [self] error in
                self.activityIndicatorView.stopAnimating()
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )
    }

    func setAlert() {
        // アラート作成
        let alert = UIAlertController(title: "来週の目標を設定しました", message: "こちらの設定は来週の日曜日からスタートです", preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func clearAlert() {
        // アラート作成
        let alert = UIAlertController(title: "目標達成おめでとうございます", message: self.clear_point + "Pを付与しました", preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }

}

extension Calendar {

    //MARK: - Week operations

    func startOfWeek(for date:Date) -> Date {
        let comps = self.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        return self.date(from: comps)!
    }

    func endOfWeek(for date:Date) -> Date {
        return nextWeek(for: date)
    }

    func previousWeek(for date:Date) -> Date {
        return move(date, byWeeks: -1)
    }

    func nextWeek(for date:Date) -> Date {
        return move(date, byWeeks: 1)
    }

    //MARK: - Month operations

    func startOfMonth(for date:Date) -> Date {
        let comps = dateComponents([.month, .year], from: date)
        return self.date(from: comps)!
    }

    func endOfMonth(for date:Date) -> Date {
        return nextMonth(for: date)
    }

    func previousMonth(for date:Date) -> Date {
        return move(date, byMonths: -1)
    }

    func nextMonth(for date:Date) -> Date {
        return move(date, byMonths: 1)
    }

    //MARK: - Move operations

    func move(_ date:Date, byWeeks weeks:Int) -> Date {
        return self.date(byAdding: .weekOfYear, value: weeks, to: startOfWeek(for: date))!
    }

    func move(_ date:Date, byMonths months:Int) -> Date {
        return self.date(byAdding: .month, value: months, to: startOfMonth(for: date))!
    }
}
