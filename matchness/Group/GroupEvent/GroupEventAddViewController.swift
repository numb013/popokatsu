//
//  GroupEventAddViewController.swift
//  matchness
//
//  Created by user on 2019/07/17.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

class GroupEventAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerBottom: NSLayoutConstraint!
    @IBOutlet weak var usePoint: UILabel!
    var activityIndicatorView = UIActivityIndicatorView()
    
    var validate = 0
    var select_pcker_list: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
    var setDateviewTime = ""
    var vi = UIView()
    var isDate = Date()
    var newDate:NSDate = Date() as NSDate
    var start_date = ""
    var selectPicker: Int = 0
    var selectPickerItem: Int = 0
    var pcker_list: [String] = []
    var selectRow = 0
    var title_text = ""
    var event_peple:Int = 0
    var event_period:Int = 0
    var present_point:Int = 0
    var event_type:Int = 0
    var dataSource: Dictionary<String, ApiGroupList> = [:]
    var dataSourceOrder: Array<String> = []
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var error_text = ""
    var cellCount: Int = 0
    var present_text = "";
    var usePointText = "200"
    var use_peple_point = "0";
    var use_period_point = "0";
    var use_present_point = "0";

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        usePointView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }

    func load() {
        tableView.delegate = self
        tableView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.tableView.register(UINib(nibName: "ProfileEditTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileEditTableViewCell")
        self.tableView.register(UINib(nibName: "TextFiledTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFiledTableViewCell")
//        navigationController!.navigationBar.topItem!.title = ""
        tableView.tableFooterView = UIView(frame: .zero)
    }

    func usePointView() {
        self.usePointText = String(200 + Int(self.use_peple_point)! + Int(self.use_period_point)! + Int(self.use_present_point)!)
        usePoint.text = self.usePointText
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileCell")
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell


            if indexPath.row == 0 {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TextFiledTableViewCell") as! TextFiledTableViewCell
                 cell.selectionStyle = UITableViewCell.SelectionStyle.none
                 cell.title?.text = "タイトル"
                
                 cell.textFiled.delegate = self
                 cell.textFiled.tag = 0
                cell.textFiled.placeholder = "マイペースグループ"
                 cell.textFiled?.text = self.title_text
                 return cell
             }


            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "参加人数 (自分を含めた人数)"
                cell.detail?.text = ApiConfig.EVENT_PEPLE_LIST[self.event_peple ?? 0]
                return cell
            }

            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "期間"
                cell.detail?.text = ApiConfig.EVENT_PERIOD_LIST[self.event_period ?? 0]
                return cell
            }

            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "賞金"
                cell.detail?.text = ApiConfig.EVENT_PRESENT_POINT[self.present_point ?? 0]
                return cell
            }
            if indexPath.row == 4 {
                let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "groupAddCell")
                cell.textLabel!.numberOfLines = 0
                cell.backgroundColor =  UIColor.clear
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                var text = "グループを作成するには200ポイント必要です。\nなお参加人数、期間、賞金の設定で追加ポイントが発生します。\n\n【参加人数】\n4人:0ポイント、5人:200ポイント、6人:400ポイント、7人:600ポイント、8人:800ポイント\n\n【期間】\n2日:0ポイント、3日:200ポイント、4日:400ポイント、5日:600ポイント、6日:800ポイント、7日:1000ポイント、14日:2000ポイント"

                cell.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
                cell.textLabel!.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                cell.textLabel!.text = text
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickerView.selectRow(0, inComponent: 0, animated: false)
        if indexPath.row == 1 {
            self.selectPicker = 1
            self.pcker_list = ApiConfig.EVENT_PEPLE_LIST
            self.selectRow = self.event_peple ?? 0
        }
        if indexPath.row == 2 {
            self.selectPicker = 2
            self.pcker_list = ApiConfig.EVENT_PERIOD_LIST
            self.selectRow = self.event_period ?? 0
        }
        if indexPath.row == 3 {
            self.selectPicker = 3
            self.pcker_list = ApiConfig.EVENT_PRESENT_POINT
            self.selectRow = self.present_point ?? 0
        }
        if indexPath.row != 4 {
            pickerView.selectRow(self.selectRow, inComponent: 0, animated: false)
            dismissPicker()
            PickerPush()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
             return 260 //自動設定
        }
        if indexPath.row == 5 {
             return 100 //自動設定
        }
        return 60
    }
    
    @IBAction func pickerSelectButton(_ sender: Any) {
        if self.selectPicker == 1 {
            self.event_peple = self.select_pcker_list[self.selectPicker] ?? 0
            self.use_peple_point = ApiConfig.PEPLE_POINT[self.event_peple ?? 0]
        }
        if self.selectPicker == 2 {
            self.event_period = self.select_pcker_list[self.selectPicker] ?? 0
            self.use_period_point = ApiConfig.PERIOD_POINT[self.event_period ?? 0]
        }
        if self.selectPicker == 3 {
            self.present_point = self.select_pcker_list[self.selectPicker] ?? 0
            self.use_present_point = ApiConfig.PRESENT_POINT[self.present_point ?? 0]
        }
        usePointView()
        dismissPicker()
        tableView.reloadData()
        self.vi.removeFromSuperview()
    }

    @IBAction func pickerCloseButton(_ sender: Any) {
        dismissPicker()
    }
    
    func PickerPush(){
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5,animations: {
            //1:ノーマル 2:XR
            if UIScreen.main.nativeBounds.height >= 1792 {
                self.pickerBottom.constant = -240
            } else {
                self.pickerBottom.constant = -260
            }
            self.pickerView.updateConstraints()
            self.tableView.updateConstraints()
            self.view.layoutIfNeeded()
        })
    }
    
    func dismissPicker(){
        UIView.animate(withDuration: 0.5,animations: {
            self.pickerBottom.constant = 300
            self.pickerView.updateConstraints()
            self.tableView.updateConstraints()
            self.view.layoutIfNeeded()
        })
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pcker_list.count
    }

    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        if (self.pcker_list.count > row) {
            return self.pcker_list[row]
        } else {
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.select_pcker_list[self.selectPicker] = row
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var tag = textField.tag
        print(textField.text!)
        if tag == 0 {
            self.title_text = textField.text!
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        print(textField.text!)
        if tag == 0 {
            self.title_text = textField.text!
        }
        textField.resignFirstResponder()
        return
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        self.title_text = textField.text!
        textField.resignFirstResponder()
        return true
    }
    func validator(_ status:Int){
        self.activityIndicatorView.stopAnimating()
        
        if status == 1 {
            self.error_text = "タイトルは必須になります"
        }
        if status == 2 {
            self.error_text = "参加人数を選択して下さい"
        }
        if status == 3 {
            self.error_text = "期間を選択して下さい"
        }
        // アラート作成
        let alert = UIAlertController(title: "入力して下さい", message: self.error_text, preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }

    @IBAction func addButton(_ sender: Any) {
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        let alertController:UIAlertController =
            UIAlertController(title:"グループを作成していいですか？",message: "作成するには" + self.usePointText + "pポント必要になります",preferredStyle: .alert)
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // Default のaction
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "作成する",style: .default){
                (action:UIAlertAction!) -> Void in

                self.apiRequest()

            }
        // Cancel のaction
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "キャンセル",style: .destructive){
                (action:UIAlertAction!) -> Void in
                // 処理
                print("キャンセル")
            }
        cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
        defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
        // actionを追加
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        // UIAlertControllerの起動
        present(alertController, animated: true, completion: nil)
    }
    
    func apiRequest() {
        let parameters = [
            "title": self.title_text,
            "use_point": self.usePointText,
            "event_peple": self.event_peple,
            "present_point": self.present_point,
            "event_type": self.event_type,
            "event_period": self.event_period
        ] as [String:Any]
        
        print("エラーーー")
        dump(parameters)
        
        
        if parameters["title"] as! String == "" {
            self.validator(1)
            return
        }
        if parameters["event_peple"] as! Int == 0 {
            self.validator(2)
            return
        }
        if parameters["event_period"] as! Int == 0 {
            self.validator(3)
            return
        }
        
        API.requestHttp(POPOAPI.base.createGroup, parameters: parameters,success: { [self] (response: ApiStatus) in
            let alertController:UIAlertController =
                UIAlertController(title:"グループを作成しました",message: "\n参加希望が届いたら選択して\nグループを開催しよう！",preferredStyle: .alert)
            // Default のaction
            let backView = alertController.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "閉じる",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                    // 処理
                    print("キャンセル")
                    self.activityIndicatorView.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                    self.close()
                })
            cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
            // actionを追加
            alertController.addAction(cancelAction)
            // UIAlertControllerの起動
            present(alertController, animated: true, completion: nil)
            
            
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }

    func pointAlert(){
        let alertController:UIAlertController =
            UIAlertController(title:"ポイントが不足しています",message: "ポイント変換が必要です", preferredStyle: .alert)
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // Default のaction
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
                (action:UIAlertAction!) -> Void in
                // 処理
                let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
                self.navigationController?.pushViewController(vc, animated: true)

            })
        // Cancel のaction
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                (action:UIAlertAction!) -> Void in
                // 処理
                print("キャンセル")
            })
        cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
        defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
        // actionを追加
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        // UIAlertControllerの起動
        present(alertController, animated: true, completion: nil)
    }
}
