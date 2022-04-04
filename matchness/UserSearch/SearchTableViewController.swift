//
//  ProfileEditViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerBottom: NSLayoutConstraint!

    var vi = UIView()
    var selectPicker: Int = 0
    var pcker_list: [String] = []
    var select_pcker_list: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
    var freeword = ""
    var work: Int = 0
    var prefecture_id: Int = 0
    var blood_type: Int = 0
    var fitness_parts_id: Int = 0
    var age_id: Int = 0
    var sex: Int = 0
    var selectRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        pickerView.delegate   = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        self.userDefaults.set(0, forKey: "searchOnOff")
        if ((self.userDefaults.object(forKey: "searchFreeword")) != nil) {
            self.freeword = (self.userDefaults.object(forKey: "searchFreeword") as? String)!
        }
        if ((self.userDefaults.object(forKey: "searchWork")) != nil) {
            self.work = Int((self.userDefaults.object(forKey: "searchWork") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchPrefectureId")) != nil) {
            self.prefecture_id = Int((self.userDefaults.object(forKey: "searchPrefectureId") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchBloodType")) != nil) {
            self.blood_type = Int((self.userDefaults.object(forKey: "searchBloodType") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchFitnessPartsId")) != nil) {
            self.fitness_parts_id = Int((self.userDefaults.object(forKey: "searchFitnessPartsId") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchSex")) != nil) {
            self.sex = Int((self.userDefaults.object(forKey: "searchSex") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchAgeId")) != nil) {
            self.age_id = Int((self.userDefaults.object(forKey: "searchAgeId") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchBloodType")) != nil) {
            self.blood_type = Int((self.userDefaults.object(forKey: "searchBloodType") as? String)!)!
        }
        if ((self.userDefaults.object(forKey: "searchFitnessPartsId")) != nil) {
            self.fitness_parts_id = Int((self.userDefaults.object(forKey: "searchFitnessPartsId") as? String)!)!
        }

        self.tableView.register(UINib(nibName: "ProfileEditTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileEditTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)
        self.navigationItem.title = "検索"
        navigationController!.navigationBar.topItem!.title = ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return ""
//    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.tintColor = #colorLiteral(red: 0.9499146342, green: 0.9500735402, blue: 0.9498936534, alpha: 1)
        header.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        pickerView.delegate   = self
        pickerView.dataSource = self

        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileCell")
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell

                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "性別"
                cell.detail?.text = ApiConfig.SEX_LIST[self.sex ?? Int((userDefaults.object(forKey: "searchSex") as? String)!)!]
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell

                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "痩せたい箇所"
                cell.detail?.text = ApiConfig.FITNESS_LIST[self.fitness_parts_id ?? Int((userDefaults.object(forKey: "searchFitnessPartsId") as? String)!)!]
                return cell
            }
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "年齢"
                cell.detail?.text = ApiConfig.SEARCH_AGE_LIST[self.age_id ?? Int((userDefaults.object(forKey: "searchAgeId") as? String)!)!]
                return cell
            }
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell

                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "職業"
                cell.detail?.text = ApiConfig.WORK_LIST[self.work ?? Int((userDefaults.object(forKey: "searchWork") as? String)!)!]
                return cell
            }
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell

                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "居住地"
                cell.detail?.text = ApiConfig.PREFECTURE_LIST[self.prefecture_id ?? 0]
                return cell
            }

            if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell

                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "血液型"
                cell.detail?.text = ApiConfig.BLOOD_LIST[self.blood_type ?? Int((userDefaults.object(forKey: "searchBloodType") as? String)!)!]
                return cell
            }
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickerView.selectRow(0, inComponent: 0, animated: false)

        if indexPath.row == 0 {
            self.selectPicker = 0
            self.pcker_list = ApiConfig.SEX_LIST
            self.selectRow = self.sex ?? 0
        }
        if indexPath.row == 1 {
            self.selectPicker = 1
            self.pcker_list = ApiConfig.FITNESS_LIST
            self.selectRow = self.fitness_parts_id ?? 0
        }
        if indexPath.row == 2 {
            self.selectPicker = 2
            self.pcker_list = ApiConfig.SEARCH_AGE_LIST
            self.selectRow = self.age_id ?? 0
        }
        if indexPath.row == 3 {
            self.selectPicker = 3
            self.pcker_list = ApiConfig.WORK_LIST
            self.selectRow = self.work ?? 0
        }
        if indexPath.row == 4 {
            self.selectPicker = 4
            self.pcker_list = ApiConfig.PREFECTURE_LIST
            self.selectRow = self.prefecture_id ?? 0
        }

        if indexPath.row == 5 {
            self.selectPicker = 5
            self.pcker_list = ApiConfig.BLOOD_LIST
            self.selectRow = self.blood_type ?? 0
        }

        pickerView.selectRow(self.selectRow, inComponent: 0, animated: false)
        dismissPicker()
        PickerPush()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func aaaa() {
        tableView.reloadData()
    }

    @IBAction func pickerSelectButton(_ sender: Any) {
        if self.selectPicker == 0 {
            self.sex = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 1 {
            self.fitness_parts_id = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 2 {
            self.age_id = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 3 {
            self.work = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 4 {
            self.prefecture_id = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 5 {
            self.blood_type = self.select_pcker_list[self.selectPicker] ?? 0
        }


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
                self.pickerBottom.constant = -150
            } else {
                self.pickerBottom.constant = -280
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
        self.freeword = textField.text!
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        self.freeword = textField.text!

        textField.resignFirstResponder()
        return
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        var tag = textField.tag
        self.freeword = textField.text!
        textField.resignFirstResponder()
        return true
    }

    @IBAction func searchResetButton(_ sender: Any) {
        userDefaults.removeObject(forKey: "searchFreeword")
        self.freeword = ""

        userDefaults.removeObject(forKey: "searchWork")
        self.work = 0

        userDefaults.removeObject(forKey: "searchPrefectureId")
        self.prefecture_id = 0

        userDefaults.removeObject(forKey: "searchBloodType")
        self.blood_type = 0

        userDefaults.removeObject(forKey: "searchFitnessPartsId")
        self.fitness_parts_id = 0

        userDefaults.removeObject(forKey: "searchSex")
        self.sex = 0

        userDefaults.removeObject(forKey: "searchAgeId")
        self.age_id = 0

        self.select_pcker_list = [0, 0, 0, 0, 0, 0, 0, 0]
        tableView.reloadData()
    }
    
    @IBAction func searchButton(_ sender: Any) {
        if (self.freeword != nil) {
            UserDefaults.standard.set(self.freeword, forKey: "searchFreeword")
        }
        if (self.work != nil) {
            UserDefaults.standard.set(String(self.work), forKey: "searchWork")
        }
        if (self.fitness_parts_id != nil) {
            UserDefaults.standard.set(String(self.fitness_parts_id), forKey: "searchFitnessPartsId")
        }
        if (self.blood_type != nil) {
            UserDefaults.standard.set(String(self.blood_type), forKey: "searchBloodType")
        }
        if (self.age_id != nil) {
            UserDefaults.standard.set(String(self.age_id), forKey: "searchAgeId")
        }
        if (self.prefecture_id != nil) {
            UserDefaults.standard.set(String(self.prefecture_id), forKey: "searchPrefectureId")
        }
        if (self.sex != nil) {
            UserDefaults.standard.set(String(self.sex), forKey: "searchSex")
        }

        UserDefaults.standard.set(1, forKey: "searchOnOff")

        
        self.navigationController?.popViewController(animated: true)

    }
    
    
}
