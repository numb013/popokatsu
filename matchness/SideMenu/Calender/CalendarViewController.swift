//
//  ViewController.swift
//  Calender
//
//  Created by 中西康之 on 2019/05/15.
//  Copyright © 2019 中西康之. All rights reserved.
//

import UIKit
import HealthKit

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }
    var daysArray: [[String:String]]! { get set }
}

//MARK:- UIViewController
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ViewLogic {

    @IBOutlet weak var navi: UINavigationItem!
    let userDefaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var cal = Calendar.current
    var setDay = Date()
    let store = HKHealthStore()
    
    var nowYear = 0
    var nowMonth = 0
    var nowDay:Int = 0
    
    var isYear = 0
    var isMonth = 0
    var isDay:Int = 0
    
    var setdaytime = "2021年"
    
    //MARK: Properties
    var numberOfWeeks: Int = 0
    var daysArray: [[String:String]]!
    private var requestForCalendar: RequestForCalendar?
    
    private let date = DateItems.ThisMonth.Request()
    private let daysPerWeek = 7
    private var thisYear: Int = 0
    private var thisMonth: Int = 0
    private var today: Int = 0
    private var days: Int = 0
    private var isToday = true
    private let dayOfWeekLabel = ["日", "月", "火", "水", "木", "金", "土"]
    private var monthCounter = 0
    private var lastSelectedCellRow:Int? = nil
    
    @IBOutlet weak var tableView: UITableView!
    //MARK: UI Parts
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func prevBtn(_ sender: UIBarButtonItem) { prevMonth() }
    @IBAction func nextBtn(_ sender: UIBarButtonItem) { nextMonth() }
    
    //MARK: Initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dependencyInjection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dependencyInjection()
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
        settingLabel()
        getToday()
    }

    
    //MARK: Setting
    private func dependencyInjection() {
        let viewController = self
        let calendarController = CalendarController()
        let calendarPresenter = CalendarPresenter()
        let calendarUseCase = CalendarUseCase()
        viewController.requestForCalendar = calendarController
        calendarController.calendarLogic = calendarUseCase
        calendarUseCase.responseForCalendar = calendarPresenter
        calendarPresenter.viewLogic = viewController
    }
    
    private func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        requestForCalendar?.requestNumberOfWeeks(request: date)
        requestForCalendar?.requestDateManager(request: date)
        
        collectionView.register(UINib(nibName: "CalenderCell", bundle: nil), forCellWithReuseIdentifier: "CalenderCell")
        
        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.register(UINib(nibName: "CalenderTextCell", bundle: nil), forCellReuseIdentifier: "CalenderTextCell")
    }
    
    private func settingLabel() {
        self.navi.title = "\(String(date.year))年\(String(date.month))月"
    }
    
    private func getToday() {
        thisYear = date.year
        thisMonth = date.month
        today = date.day
        
        nowYear = date.year
        nowMonth = date.month
        nowDay = date.day
    }
    
    // 今日の歩数を取得するための関数
    func getDayStep(completion: @escaping (Double) -> Void) {
        dateFormatter.dateFormat = "MM/dd HH:mm"
        let selectDate =  dateFormatter.string(from: self.setDay)
        var component = NSCalendar.current.dateComponents([.year, .month, .day], from: self.setDay)
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

}

//MARK:- Setting Button Items
extension CalendarViewController {
    
    private func nextMonth() {
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    private func prevMonth() {
        monthCounter -= 1
        commonSettingMoveMonth()
    }
    
    private func commonSettingMoveMonth() {
        daysArray = nil
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        requestForCalendar?.requestNumberOfWeeks(request: moveDate)
        requestForCalendar?.requestDateManager(request: moveDate)
        self.navi.title = "\(String(moveDate.year))年\(String(moveDate.month))月"
        isToday = thisYear == moveDate.year && thisMonth == moveDate.month ? true : false
        nowYear = moveDate.year
        nowMonth = moveDate.month
        collectionView.reloadData()
    }
}

//MARK:- UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            let label = cell.contentView.viewWithTag(1) as! UILabel
            label.backgroundColor = .clear
            label.font = UIFont.systemFont(ofSize: 14.0)
            switch indexPath.row % daysPerWeek {
                case 0: label.textColor = .red
                case 6: label.textColor = .blue
                default: label.textColor = .black
            }
            label.text = dayOfWeekLabel[indexPath.row]
            cell.selectedBackgroundView = nil
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
        switch indexPath.row % daysPerWeek {
            case 0: cell.day.textColor = .red
                cell.sideLine.isHidden = false
            case 6: cell.day.textColor = .blue
                    cell.sideLine.isHidden = true
            default: cell.day.textColor = .black
                 cell.sideLine.isHidden = false
        }
        showDate(indexPath.section, indexPath.row, cell)
        cell.memoImage.isHidden = true
        cell.dayEvents[0].text = ""
        
        cell.graphview.backgroundColor = #colorLiteral(red: 0, green: 0.7523386478, blue: 0.3318005204, alpha: 0)
        cell.graphview_2.backgroundColor = #colorLiteral(red: 0, green: 0.7523386478, blue: 0.3318005204, alpha: 0)
        cell.dayEvents[1].text = ""
        
        if daysArray[indexPath.row]["main"] != nil {
            isYear = nowYear
            isMonth = nowMonth
            isDay = Int(daysArray[indexPath.row]["main"]!)!
        } else if daysArray[indexPath.row]["pre"] != nil {
            isYear = nowMonth != 1 ? nowYear : nowYear-1
            isMonth = nowMonth != 1 ? nowMonth-1 : 12
            isDay = Int(daysArray[indexPath.row]["pre"]!)!
        } else {
            isYear = nowMonth != 12 ? nowYear : nowYear+1
            isMonth = nowMonth != 12 ? nowMonth+1 : 1
            isDay = Int(daysArray[indexPath.row]["next"]!)!
        }
        
        self.setDay = cal.date(from: DateComponents(year: isYear, month: isMonth, day: isDay, hour: 00, minute: 00))!
        
        getDayStep { (result) in
            DispatchQueue.main.async {
                if Int(result) > 0 {
                    if Int(result) > 20000 {
                        cell.graphview.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.8196078431, blue: 0.6431372549, alpha: 0.85)
                        cell.topLine.constant = 0
                    } else if Int(result) > 10000 {
                        var v_height = (20000 - Double(result)) / 10000
                        cell.graphview_2.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.8196078431, blue: 0.6431372549, alpha: 0.5)
                        cell.topLine_2.constant = CGFloat(Double(cell.frame.height) * v_height)
                        cell.graphview.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.8196078431, blue: 0.6431372549, alpha: 0.25)
                        cell.topLine.constant = 0
                    } else if Int(result) <= 10000 {
                        var v_height = (10000 - Double(result)) / 10000
                        cell.graphview.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.8196078431, blue: 0.6431372549, alpha: 0.25)
                        cell.topLine.constant = CGFloat(Double(cell.frame.height) * v_height)
                    }
                    cell.dayEvents[1].text = String(Int(result)) + "歩"
                } else {
                    cell.topLine.constant = cell.frame.height
                }
            }
        }
        return cell
    }

    private func showDate(_ section: Int, _ row: Int, _ cell: CalenderCell) {
        if daysArray[row]["main"] != nil {
            cell.day.text = daysArray[row]["main"]
            cell.backgroundColor = .white
            markToday(cell)
        } else if daysArray[row]["pre"] != nil {
            cell.day.text = daysArray[row]["pre"]
            cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        } else {
            cell.day.text = daysArray[row]["next"]
            cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        }
    }
    
    private func markToday(_ cell: CalenderCell) {
        cell.backgroundColor = .white
        if isToday, today.description == cell.day.text {
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.6915919781, blue: 0.8323478103, alpha: 1)
            cell.graphview.backgroundColor = #colorLiteral(red: 1, green: 0.8456724286, blue: 0.9871529937, alpha: 0.5)
            cell.graphview_2.backgroundColor = #colorLiteral(red: 1, green: 0.8456724286, blue: 0.9871529937, alpha: 0.7)
            setdaytime = String(nowYear) + "/" + String(nowMonth) + "/" + cell.day.text!
            inputTextViewUpdate(setdaytime)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalenderCell
        cell.backgroundColor = #colorLiteral(red: 1, green: 0.8456724286, blue: 0.9871529937, alpha: 0.7)

        setdaytime = String(nowYear) + "/" + String(nowMonth) + "/" + cell.day.text!
        inputTextViewUpdate(setdaytime)
        
        if lastSelectedCellRow != nil {
            let index = IndexPath(row: lastSelectedCellRow!, section: 1)
            let lastCell = self.collectionView.cellForItem(at: index) as! CalenderCell
            if today == Int(lastCell.day.text!) && daysArray[lastSelectedCellRow!]["main"] != nil {
                lastCell.backgroundColor = #colorLiteral(red: 1, green: 0.6915919781, blue: 0.8323478103, alpha: 1)
            } else if daysArray[lastSelectedCellRow!]["pre"] != nil || daysArray[lastSelectedCellRow!]["next"] != nil {
                lastCell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            } else {
                lastCell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        lastSelectedCellRow = indexPath.row
    }
    
    func inputTextViewUpdate(_ setdaytime: String) {
        let tableCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CalenderTextCell
        tableCell.startDate?.text = setdaytime
        if var weightAndMemo = self.userDefaults.stringArray(forKey: setdaytime) {
            tableCell.weightLabel?.text = "体重 : " + weightAndMemo[0] + "kg"
            tableCell.memoLabel?.text = weightAndMemo[1]
        } else {
            tableCell.weightLabel?.text = ""
            tableCell.memoLabel?.text = ""
        }
    }
}

//MARK:- UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekWidth = Int(collectionView.frame.width) / daysPerWeek
        let weekHeight = weekWidth - 20
        let dayWidth = weekWidth
        let dayHeight = (Int(collectionView.frame.height) - weekHeight) / numberOfWeeks
        return indexPath.section == 0 ? CGSize(width: weekWidth, height: weekHeight) : CGSize(width: dayWidth, height: dayHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let surplus = Int(collectionView.frame.width) % daysPerWeek
        let margin = CGFloat(surplus)/2.0
        return UIEdgeInsets(top: 0.0, left: margin, bottom: 1.5, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

    
    
    //テーブル処理 //////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalenderTextCell") as! CalenderTextCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.startDate.textColor = #colorLiteral(red: 0.4859109521, green: 0.4859964848, blue: 0.4858996868, alpha: 1)
        cell.weightLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        cell.memoLabel.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputWeight()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func inputWeight() {
       //アラートコントローラー
        let alert = UIAlertController(title: "体重 / メモ", message: "\n" + setdaytime, preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        var now_date = dateFormater.string(from: Date())
        //OKボタンを生成
        let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction) in
            var weightAndMemo = ["", ""]
            if var weightAndMemo = self.userDefaults.stringArray(forKey: setdaytime) {}
            //複数のtextFieldのテキストを格納
             guard let textFields:[UITextField] = alert.textFields else {return}
             //textからテキストを取り出していく
             for textField in textFields {
                switch textField.tag {
                     case 1:
                        weightAndMemo[0] = textField.text!
                        self.userDefaults.set(weightAndMemo, forKey: setdaytime)
                        if now_date == setdaytime {
                            self.userDefaults.set(textField.text, forKey: "weight")
                        }
                     case 2:
                        weightAndMemo[1] = textField.text!
                        self.userDefaults.set(weightAndMemo, forKey: setdaytime)
                    default: break
                 }
             }
            inputTextViewUpdate(setdaytime)
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
        alert.addTextField { [self] (text:UITextField!) in
            text.textColor = #colorLiteral(red: 0.41229707, green: 0.4098508656, blue: 0.4141805172, alpha: 1)
            text.textAlignment = NSTextAlignment.center
            text.font = UIFont.boldSystemFont(ofSize: 20)
            text.keyboardType = UIKeyboardType.decimalPad //数字と小数点のみ表示
            text.placeholder = "体重を入力してね"
            //１つ目のtextFieldのタグ
            text.text = ""
            if var weightAndMemo = self.userDefaults.stringArray(forKey: setdaytime) {
                text.text = weightAndMemo[0] as! String
            }
            text.tag = 1
        }
        alert.addTextField { [self] (text:UITextField!) in
            text.textColor = #colorLiteral(red: 0.41229707, green: 0.4098508656, blue: 0.4141805172, alpha: 1)
             text.textAlignment = NSTextAlignment.center
             text.font = UIFont.boldSystemFont(ofSize: 20)
             text.placeholder = "メモ"
             //2つ目のtextFieldのタグ
            text.text = ""

            if var weightAndMemo = self.userDefaults.stringArray(forKey: setdaytime) {
                text.text = weightAndMemo[1] as! String
            }
             text.tag = 2
         }
        //アラートを表示
         present(alert, animated: true, completion: nil)
    }
    

}
