//
//  GraphViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/07/28.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit
import Charts

class GraphViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var segment: UISegmentedControl!

    @IBOutlet weak var targetWeightButton: UIButton!
    @IBOutlet weak var inputButton: UIButton!
    
    var lineChartView = LineChartView()
    let userDefaults = UserDefaults.standard

    let datePicker = UIDatePicker()
    var setDateviewTime = ""
    var weight = Double()
    var height = Double()
    let dateFormatter = DateFormatter()
    let now = Date()
    var set_date = Date()
    var day = 0
    var setDate = ""
    var period = 6
    var days:[String] = []
    var mouthday:[String] = []
    var hight_weigh:Double = 0.0
    var row_weigh:Double = 200.0
    var now_weigh:Double = 0.0
    
    @IBOutlet weak var segmentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var segumentHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segment.unselectedSegmentTintColor(.black)
        segment.selectedSegmentTintColor(.white)

        
        //外枠の色を指定
        self.targetWeightButton.layer.borderColor =  #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        //外枠の太さを指定
        self.targetWeightButton.layer.borderWidth = 1.0
        self.targetWeightButton.layer.cornerRadius = 6
        
        //外枠の色を指定
        self.inputButton.layer.borderColor =  #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        //外枠の太さを指定
        self.inputButton.layer.borderWidth = 1.0
        self.inputButton.layer.cornerRadius = 6
        
    }

    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       presentingViewController?.endAppearanceTransition()
        let weight = userDefaults.object(forKey: "weight")

        let height = userDefaults.object(forKey: "height")
        if weight != nil && height != nil {
            graph()
        } else {
            inputWeight()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }

    func graph() {
        lineChartView.removeFromSuperview()
        var lineChartEntry  = [ChartDataEntry]()
        self.days = []
        self.mouthday = []
        var n = 0

        for i in (0 ..< self.period).reversed() {
            let from = Date(timeInterval: TimeInterval(-60*60*24*i), since: now)
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let selectDate =  dateFormatter.string(from: from)

            mouthday.append(selectDate)
            let from_1 = Date(timeInterval: TimeInterval(-60*60*24*i), since: now)
            dateFormatter.dateFormat = "M/d"
            var selectDay =  dateFormatter.string(from: from_1)
            days.append(selectDay)
            if let weightAndMemo = userDefaults.stringArray(forKey: selectDate) {

                if self.hight_weigh < Double(Int((weightAndMemo[0] as! NSString).doubleValue)) {
                    self.hight_weigh = Double(Int((weightAndMemo[0] as! NSString).doubleValue))
                }
                if self.row_weigh > Double(Int((weightAndMemo[0] as! NSString).doubleValue)) {
                    self.row_weigh = Double(Int((weightAndMemo[0] as! NSString).doubleValue))
                }

                let chartData = ChartDataEntry(x: Double(n), y: Double((weightAndMemo[0] as! NSString).doubleValue))
                lineChartEntry.append(chartData)
                self.now_weigh = Double((weightAndMemo[0] as! NSString).doubleValue)
            }
            n += 1
        }

        if lineChartEntry.isEmpty {
            let chartData = ChartDataEntry(x: Double(self.period), y:0.0)
            lineChartEntry.append(chartData)
        }

        let lineChartDataSet = LineChartDataSet(entries: lineChartEntry, label: "nil")
        lineChartDataSet.axisDependency = .left
        lineChartDataSet.setColor(#colorLiteral(red: 1, green: 0.6304908395, blue: 0.7219088078, alpha: 1))
        lineChartDataSet.setCircleColor(#colorLiteral(red: 1, green: 0.6304908395, blue: 0.7219088078, alpha: 1)) // our circle will be dark red
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.circleRadius = 6.5 // the radius of the node circle
        lineChartDataSet.fillAlpha = 1

        var y_height:CGFloat = segmentTopConstraint.constant + segumentHeight.constant + 60
        let rect = CGRect(x:0, y: y_height, width: self.view.frame.width, height: self.view.frame.height - 180)
        lineChartView = LineChartView(frame: rect)
        lineChartView.delegate = self
        lineChartView.data = LineChartData(dataSet: lineChartDataSet)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        lineChartView.xAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.avoidFirstLastClippingEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.axisMinimum = Double(0)
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        
        if let targetWeight_1 = self.userDefaults.object(forKey: "targetWeight") {
            if self.row_weigh > Double(Int((targetWeight_1 as! NSString).doubleValue)) {
                lineChartView.leftAxis.axisMinimum = Double(Int((targetWeight_1 as! NSString).doubleValue)) - 3.0
            } else {
                lineChartView.leftAxis.axisMinimum = row_weigh - 3.0
            }
        }
        lineChartView.leftAxis.axisMaximum = self.hight_weigh + 7
        lineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 15)
        lineChartView.leftAxis.labelTextColor =  #colorLiteral(red: 1, green: 0.6304908395, blue: 0.7219088078, alpha: 1)



        //タップ
        lineChartView.highlightPerTapEnabled = true
        //背景
        
        lineChartView.drawGridBackgroundEnabled = true
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.legend.enabled = false
        if (self.period == 6) {
            
        }
        var count = 6
        var Maximum = 5
        switch self.period {
        case 6:
            count = 6
            Maximum = 0
            lineChartView.setVisibleXRangeMaximum(Double(count))
        case 30:
            count = 30
            Maximum = 0
            lineChartView.setVisibleXRangeMaximum(Double(count))
        case 90:
            count = 55
            lineChartView.setVisibleXRangeMaximum(Double(count))
        case 180:
            count = 80
            lineChartView.setVisibleXRangeMaximum(Double(count))
        default:
            lineChartView.setVisibleXRangeMaximum(Double(count))
        }
        lineChartView.xAxis.axisMaximum = Double(self.period + Maximum)
        lineChartView.moveViewToX(Double(self.period))
        lineChartView.dragEnabled = true
        lineChartView.doubleTapToZoomEnabled = false
        if let targetWeight = userDefaults.object(forKey: "targetWeight") {
            var nokori_Weight = Double((targetWeight as! NSString).doubleValue) - self.now_weigh
            //目標ライン
            var goal = "GOAL:\(targetWeight)kg (あと" + String(floor(nokori_Weight * 10) / 10 ) + "kg)"
            let limitLine = ChartLimitLine(
                limit: Double(Int((targetWeight as! NSString).doubleValue)) as! Double,
                label: goal
            )
            limitLine.lineColor =  #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
            limitLine.lineDashLengths = [4]
            limitLine.labelPosition = .topLeft
            lineChartView.leftAxis.addLimitLine(limitLine)
        }
                
        view.addSubview(lineChartView)
    }


    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let pos = NSInteger(entry.x)
        let pos1 = NSInteger(entry.y)
        self.showMarkerView(weight: entry.y, mouthday:"\(self.mouthday[pos])")
    }

    func showMarkerView(weight:Double, mouthday:String){
        //使用气泡状的标签
        let marker = BalloonMarker(color:  #colorLiteral(red: 1, green: 0.6304908395, blue: 0.7219088078, alpha: 1),
                        font: .systemFont(ofSize: 12),
                        textColor: .white,
                        insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))

        var bmi:Double = 0.0
        if var is_height = self.userDefaults.object(forKey: "height") {
            self.height = Double((self.userDefaults.object(forKey: "height") as! NSString).doubleValue) as! Double
            var bmi_height = self.height/100
            bmi = floor(weight / (bmi_height * bmi_height) * 10) / 10
        }

        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        self.set_date = dateFormater.date(from: mouthday)!

        
        marker.chartView = self.lineChartView
        marker.minimumSize = CGSize(width: 40, height: 40)
        marker.setLabel("\(mouthday)\n\(weight) kg\n BMI：\(bmi)")
        self.lineChartView.marker = marker
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func targetWeight(_ sender: Any) {
        inputTargetWeight()
    }
    func inputTargetWeight() {
        //アラートコントローラー
         let alert = UIAlertController(title: "目標体重", message: "目標体重を入力してね", preferredStyle: .alert)
         let backView = alert.view.subviews.last?.subviews.last
         backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        //OKボタンを生成
         let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
             //複数のtextFieldのテキストを格納
             guard let textFields:[UITextField] = alert.textFields else {return}
             //textからテキストを取り出していく
             for textField in textFields {
                 switch textField.tag {
                     case 1: UserDefaults.standard.set(textField.text, forKey: "targetWeight")
                     default: break
                 }
             }
            self.graph()
         }

        okAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
         //OKボタンを追加
         alert.addAction(okAction)
         //Cancelボタンを生成
         let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (UIAlertAction) -> Void in
            print("閉じる")
         }
        cancelAction.setValue(#colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), forKey: "titleTextColor")
        //Cancelボタンを追加
         alert.addAction(cancelAction)

        alert.addTextField { (text:UITextField!) in
            text.textColor =  #colorLiteral(red: 0.41229707, green: 0.4098508656, blue: 0.4141805172, alpha: 1)
             text.textAlignment = NSTextAlignment.center
             text.font = UIFont.boldSystemFont(ofSize: 20)
             text.keyboardType = UIKeyboardType.decimalPad //数字と小数点のみ表示
             text.placeholder = "目標体重"
             text.text = ""
             if let targetWeight = self.userDefaults.object(forKey: "targetWeight") {
                 text.text = targetWeight as! String
             }
             text.tag = 1
         }
        //アラートを表示
         present(alert, animated: true, completion: nil)
    }
    
    @IBAction func inputButton(_ sender: Any) {
        inputWeight()
    }

    func inputWeight() {
       //アラートコントローラー
        let alert = UIAlertController(title: "現在の体重・身長入力", message: "入力したい日付を選択して下さい\n\n\n", preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        var now_date = dateFormater.string(from: Date())
        
        if self.setDate.isEmpty {
            self.setDate = dateFormater.string(from: self.datePicker.date)
        }
        //OKボタンを生成
         let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            var weightAndMemo = ["", ""]
            if var weightAndMemo = self.userDefaults.stringArray(forKey: self.setDate) {
                
            }
            //複数のtextFieldのテキストを格納
             guard let textFields:[UITextField] = alert.textFields else {return}
             //textからテキストを取り出していく
             for textField in textFields {
                switch textField.tag {
                     case 1:
                        weightAndMemo[0] = textField.text!
                        self.userDefaults.set(weightAndMemo, forKey: self.setDate)
                        if now_date == self.setDate {
                            self.userDefaults.set(textField.text, forKey: "weight")
                        }
                     case 2:
                        self.userDefaults.set(textField.text, forKey: "height")
                    default: break
                 }
             }
             self.graph()
        }
        okAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
        //OKボタンを追加
         alert.addAction(okAction)
         
         //Cancelボタンを生成
         let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (UIAlertAction) -> Void in
            print("閉じる")
         }
        cancelAction.setValue(#colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1), forKey: "titleTextColor")
        //Cancelボタンを追加
         alert.addAction(cancelAction)
        //TextFieldを２つ追加
        alert.addTextField { (text:UITextField!) in
            text.textColor =  #colorLiteral(red: 0.41229707, green: 0.4098508656, blue: 0.4141805172, alpha: 1)
            text.textAlignment = NSTextAlignment.center
            text.font = UIFont.boldSystemFont(ofSize: 20)
            text.keyboardType = UIKeyboardType.decimalPad //数字と小数点のみ表示
            text.placeholder = "体重を入力してね"
            //１つ目のtextFieldのタグ
            text.text = ""
            if var weightAndMemo = self.userDefaults.stringArray(forKey: self.setDate) {
                text.text = weightAndMemo[0] as! String
            }
            text.tag = 1
        }
        alert.addTextField { (text:UITextField!) in
            text.textColor =  #colorLiteral(red: 0.41229707, green: 0.4098508656, blue: 0.4141805172, alpha: 1)
             text.textAlignment = NSTextAlignment.center
             text.font = UIFont.boldSystemFont(ofSize: 20)
             text.keyboardType = UIKeyboardType.decimalPad //数字と小数点のみ表示
             text.placeholder = "身長を入力してね"
             //2つ目のtextFieldのタグ
            text.text = ""
            if let height = self.userDefaults.object(forKey: "height") {
                text.text = height as! String
            }

             text.tag = 2
         }

        datePicker.locale = Locale(identifier: "ja")
        datePicker.frame = CGRect(x : 80, y : 75, width : 100, height : 45) // 配置、サイズ
//        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.date = self.set_date
        datePicker.addTarget(self, action: #selector(setText), for: .valueChanged)
        datePicker.maximumDate = NSDate() as Date
        alert.view.addSubview(datePicker)

        self.setDate = dateFormater.string(from: self.set_date)

        //アラートを表示
         present(alert, animated: true, completion: nil)

    }
    
    @objc private func setText() {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        self.setDateviewTime = dateFormater.string(from: datePicker.date)
        self.setDate = self.setDateviewTime
    }

    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        self.hight_weigh = 0.0
        switch sender.selectedSegmentIndex {
        case 0:
            self.period = 6
            graph()
        case 1:

            self.period = 30
            graph()
        case 2:
            self.period = 90
            graph()
        case 3:
            self.period = 180
            graph()
        default:
            self.period = 6
            graph()
        }
    }
}


extension UISegmentedControl{
    func selectedSegmentTintColor(_ color: UIColor) {
        self.setTitleTextAttributes([.foregroundColor: color], for: .selected)
    }
    func unselectedSegmentTintColor(_ color: UIColor) {
        self.setTitleTextAttributes([.foregroundColor: color], for: .normal)
    }
}
