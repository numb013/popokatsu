//
//  ProfileAddViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/07/31.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import SwiftyJSON
import Foundation

class ProfileAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate,UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, detePickerProtocol{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePickerBottom: NSLayoutConstraint!
    @IBOutlet weak var pickerBottom: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    

    var select_pcker_list: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
    var image_main_param:UIImage = UIImage()
    var activityIndicatorView = UIActivityIndicatorView()

    var setDateviewTime = ""
    var vi = UIView()
    var selectPicker: Int = 0
    var selectPickerItem: Int = 0
    var pcker_list: [String] = [""]
    var selectRow = 0
    var cellCount: Int = 0
    var dataSource = [ApiProfileData]()
    var dataSourceOrder: Array<String> = []
    private var requestAlamofire: Alamofire.Request?;
    private var response: AFDataResponse<Any>?;
    let userDefaults = UserDefaults.standard
    var userProfile : NSDictionary!
    var json_data:JSON = []
    var profileImage:UIImage = UIImage()
    var image_main:String = ""
    var base64String:String = ""
    var validate = 0
    var myTextView = UITextView()
    var sex = 0

    //IDをキーにしてデータを保持
    public var errorData: Dictionary<String, ApiErrorAlert> = [String: ApiErrorAlert]();

    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnUserDataSecond()
        tableView.delegate = self
        tableView.dataSource = self
        pickerView.dataSource = self as! UIPickerViewDataSource
        pickerView.delegate = self as! UIPickerViewDelegate
        pickerView.showsSelectionIndicator = true

        self.tableView.register(UINib(nibName: "ProfileEditTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileEditTableViewCell")
        self.tableView.register(UINib(nibName: "TextFiledTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFiledTableViewCell")
        self.tableView.register(UINib(nibName: "TextAreaTableViewCell", bundle: nil), forCellReuseIdentifier: "TextAreaTableViewCell")
        self.tableView.register(UINib(nibName: "profileAddImageTableViewCell", bundle: nil), forCellReuseIdentifier: "profileAddImageTableViewCell")

        self.tableView.register(UINib(nibName: "DetePickerViewCell", bundle: nil), forCellReuseIdentifier: "DetePickerViewCell")

        view.backgroundColor = .white
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)

        addButton.layer.cornerRadius = 5.0
        tableView.tableFooterView = UIView(frame: .zero)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func delegate() {
        pickerView.delegate   = self as! UIPickerViewDelegate
        pickerView.dataSource = self as! UIPickerViewDataSource
    }

    func returnUserDataSecond() {
        API.requestHttp(POPOAPI.base.userMe, parameters: nil,success: { [self] (response: [ApiProfileData]) in
                dataSource = response
                viewPlofile()
                tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    func viewPlofile() {
        let minDateString = "1900-01-01"
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        var minDate = dateFormater.date(from: minDateString)
        let day = Date()
        let maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: day)!

        dataSource[0].name = ""
        dataSource[0].birthday = dateFormater.string(from: maximumDate)
        dataSource[0].work = 0
        dataSource[0].prefecture_id = 0
        dataSource[0].sex = 1
        dataSource[0].blood_type = 0
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if dataSource.isEmpty == false {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty == false {
            if section == 1 {
                return 5
            } else {
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1){
            return "プロフィール"
        } else if (section == 0) {
            return "画像"
        }
        return ""
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.tintColor = #colorLiteral(red: 0.9499146342, green: 0.9500735402, blue: 0.9498936534, alpha: 1)
        header.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileCell")
        var myData = dataSource[0]

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileAddImageTableViewCell") as! profileAddImageTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if (self.image_main_param.size.width != 0) {
                cell.mainImage.image = self.image_main_param
            } else {
//                cell.mainImage.image = UIImage(named: "add_image")
            }

            cell.mainImage.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage(_:)))
            cell.mainImage.addGestureRecognizer(recognizer)
            return cell
        }

        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFiledTableViewCell") as! TextFiledTableViewCell
                let attrText = NSMutableAttributedString(string: "※ ニックネーム ")
                attrText.addAttribute(.foregroundColor,value: UIColor.red, range: NSMakeRange(0, 1))
                cell.title?.attributedText = attrText
                cell.textFiled.delegate = self
                cell.textFiled.tag = 0
                cell.textFiled.placeholder = "※15文字まで"
                cell.textFiled?.text = myData.name
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                self.select_pcker_list[indexPath.row] = myData.sex ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                let attrText = NSMutableAttributedString(string: "※ 性別")
                attrText.addAttribute(.foregroundColor,value: UIColor.red, range: NSMakeRange(0, 1))
                cell.title?.attributedText = attrText
                cell.detail?.text = ApiConfig.SEX_LIST[myData.sex ?? 0]
                return cell
            }

            if indexPath.row == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetePickerViewCell") as! DetePickerViewCell
                let attrText = NSMutableAttributedString(string: "※ 誕生日")
                attrText.addAttribute(.foregroundColor,value: UIColor.red, range: NSMakeRange(0, 1))
                cell.title?.attributedText = attrText
                cell.delegate = self
                return cell
            }
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                self.select_pcker_list[indexPath.row] = myData.prefecture_id ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "居住地"
                cell.detail?.text = ApiConfig.PREFECTURE_LIST[myData.prefecture_id ?? 0]
                return cell
            }
            if indexPath.row == 4 {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
        }
        return cell
    }
    
    @objc func onTapImage(_ sender: MyTapGestureRecognizer) {
        selectImage()
    }

    private func selectImage() {
        let alertController: UIAlertController = UIAlertController(title: "カメラへアクセス", message: "登録に必要な写真に使用する為、お使いの機能をお選び下さい。", preferredStyle:  UIAlertController.Style.alert)
        let libraryAction = UIAlertAction(title: "ライブラリから選択", style: .default) { (UIAlertAction) -> Void in
            self.selectFromLibrary()
        }
        let cameraAction = UIAlertAction(title: "カメラを起動", style: .default) { (UIAlertAction) -> Void in
            self.selectFromCamera()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (UIAlertAction) -> Void in
            print("閉じる")
        }
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func selectFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラ許可をしていない時の処理")
        }
    }
    
    private func selectFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラロール許可をしていない時の処理")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 90% に縮小
        let resizedImage = self.resizeImage(image: info[UIImagePickerController.InfoKey.editedImage] as! UIImage, ratio: 0.9)
        self.image_main_param = resizedImage
        let jpegCompressionQuality: CGFloat = 0.9 // Set this to whatever suits your purpose

        self.base64String = (resizedImage.jpegData(compressionQuality: jpegCompressionQuality)?.base64EncodedString())!
        self.image_main = self.base64String
        tableView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 画像を指定された比率に縮小
    func resizeImage(image: UIImage, ratio: CGFloat) -> UIImage {
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x:0, y:0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pcker_list = []
        self.pickerView.selectRow(0, inComponent: 0, animated: false)

        if indexPath.row == 0 {
            self.selectPicker = 0
        }
        if indexPath.row == 1 {
            self.selectPicker = 1
            self.pcker_list = ApiConfig.SEX_LIST
            self.selectRow = self.dataSource[0].sex ?? 0
        }
        if indexPath.row == 3 {
            self.selectPicker = 3
            self.pcker_list = ApiConfig.PREFECTURE_LIST
            self.selectRow = self.dataSource[0].prefecture_id ?? 0
        }

        if (indexPath.row != 0) {
            self.pickerView.reloadAllComponents()
            PickerPush()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func pickerSelectButton(_ sender: Any) {
        if self.selectPicker == 0 {

        }
        if self.selectPicker == 1 {
            self.dataSource[0].sex = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 3 {
            self.dataSource[0].prefecture_id = self.select_pcker_list[self.selectPicker] ?? 0
        }
        tableView.reloadData()
        self.vi.removeFromSuperview()
        dismissPicker()
    }

    @IBAction func pickerCloseButton(_ sender: Any) {
        dismissPicker()
    }

    func PickerPush(){
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5,animations: {
            self.pickerBottom.constant = -250
            self.tableView.updateConstraints()
            self.view.layoutIfNeeded()
        })
    }

    func dismissPicker(){
        UIView.animate(withDuration: 0.5,animations: {
            self.pickerBottom.constant = 300
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250
        } else if indexPath.section == 2 {
            return 400
        }
        return 60
    }
    
    func detePickerSelect(date: String) {
        self.dataSource[0].birthday = date
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var tag = textField.tag
        self.dataSource[0].name = textField.text!
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        self.dataSource[0].name = textField.text!
        textField.resignFirstResponder()
        return
    }

    @objc func onClickCommitButton (sender: UIButton) {
        if(myTextView.isFirstResponder){
            myTextView.resignFirstResponder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var tag = textField.tag
        // キーボードを閉じる
        self.dataSource[0].name = textField.text!
        textField.resignFirstResponder()
        return true
    }

    func validator(_ status: Int){
        self.activityIndicatorView.stopAnimating()
        // アラート作成
        var alert = UIAlertController(title: "入力して下さい", message: "必須項目（＊印）を選択して下さい", preferredStyle: .alert)
        if status == 1 {
            alert = UIAlertController(title: "入力して下さい", message: "ニックネームを入力して下さい", preferredStyle: .alert)
        } else if status == 3 {
            alert = UIAlertController(title: "入力して下さい", message: "プロフィール画像を選択して下さい", preferredStyle: .alert)
        } else if status == 2 {
            alert = UIAlertController(title: "入力して下さい", message: "ニックネームは15文字までになります", preferredStyle: .alert)
        } else if status == 4 {
            alert = UIAlertController(title: "性別は必須項目になります", message: "性別を選択して下さい", preferredStyle: .alert)
        }

        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    @IBAction func profileEdit(_ sender: Any) {
        activityIndicatorView.startAnimating()
//        /****************
//         APIへリクエスト（ユーザー取得）
//         *****************/
        let parameters = [
            "id": self.dataSource[0].id ?? 0,
            "profile_text": myTextView.text,
            "name": self.dataSource[0].name,
            "birthday": self.dataSource[0].birthday,
            "sex": self.dataSource[0].sex ?? 0,
            "prefecture_id": self.dataSource[0].prefecture_id ?? 0,
            "image_main": self.image_main ?? ""
        ] as! [String:Any]
        
        if ((parameters["name"]! as AnyObject).trimmingCharacters(in: .whitespacesAndNewlines).count == 0) {
            validator(1)
            return
        }
        if ((parameters["name"]! as! String).count > 15) {
            validator(2)
            return
        }
        if (parameters["sex"] as! Int == 0) {
            validator(4)
            return
        }
        self.sex = self.dataSource[0].sex as! Int

        API.requestHttp(POPOAPI.base.profileEdit, parameters: parameters,success: { [self] (response: [ApiProfileData]) in
                print("きてます？きてます？きてます？きてます？")
                self.activityIndicatorView.stopAnimating()
                self.userDefaults.set("1", forKey: "login_step_2")
                completeJamp()
            },
            failure: { [self] error in
                print(error)
                // self.errorData = model.errorData;
                // Alert.common(alertNum: self.errorData, viewController: self)
            }
        )
        
//
//
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        query["id"] = String(self.dataSource["0"]?.id ?? "0")
//        query["profile_text"] = myTextView.text
//        query["name"] = self.dataSource["0"]?.name
//        query["birthday"] = self.dataSource["0"]?.birthday
//        query["sex"] = String(self.dataSource["0"]?.sex ?? 0)
//        query["prefecture_id"] = String(self.dataSource["0"]?.prefecture_id ?? 0)
//        query["image_main"] = self.image_main ?? ""
//
//        if (query["name"]!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0) {
//            validator(1)
//        }
//
//        if (query["name"]!.count > 15) {
//            validator(2)
//        }
//        if (query["sex"] == "0") {
//            validator(4)
//        }
//        self.sex = self.dataSource["0"]?.sex as! Int
//
//            //リクエスト実行
//            if( !requestProfileAddModel.requestApi(url: requestUrl, addQuery: query) ){
//
//            }

    }
    
    func completeJamp() {
        print("ここはきてまうか？？？？？")
        self.activityIndicatorView.stopAnimating()
        self.userDefaults.set(self.sex, forKey: "sex")
        self.userDefaults.set(1, forKey: "status")
        self.performSegue(withIdentifier: "toTerm", sender: nil)
    }
}
