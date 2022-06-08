//
//  ProfileEditViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import FirebaseStorage
import SDWebImage

class ProfileEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, detePickerProtocol {

    let userDefaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerBottom: NSLayoutConstraint!

    @IBOutlet weak var editButton: UIButton!
    
    var setDateviewTime = ""
    var profile_text = ""
    var vi = UIView()
    var isDate = Date()
    var selectPicker: Int = 0
    var selectPickerItem: Int = 0
    var select_pcker_list: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var pcker_list: [String] = []
    var cellCount: Int = 0
    var dataSource: Dictionary<String, ApiUserDetailDate> = [:]
    var dataSourceOrder: Array<String> = []
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var delete_str = ""
    var selectRow = 0
    var selectTextFild = 0
    var scroll = 0
    var nick_name = ""
    var image_type = ""
    var activityIndicatorView = UIActivityIndicatorView()
    var image_main_param:UIImage = UIImage()
    var image_1_param:UIImage = UIImage()
    var image_2_param:UIImage = UIImage()
    var image_3_param:UIImage = UIImage()
    var image_4_param:UIImage = UIImage()

    var image_main:String = ""
    var image_1:String = ""
    var image_2:String = ""
    var image_3:String = ""
    var image_4:String = ""
    var base64String:String = ""
    var myTextView = UITextView()
    var validate = 0
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;

    var top_status = 0
    
    
    private var presenter: ProfileEditInput!
    func inject(presenter: ProfileEditInput) {
        // このinputがpresenterのこと
        self.presenter = presenter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.

        pickerView.showsSelectionIndicator = true
        myTextView.delegate = self
        
        myTextView.tag = 1111111
        
        self.tableView.register(UINib(nibName: "ProfileEditTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileEditTableViewCell")
        self.tableView.register(UINib(nibName: "TextFiledTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFiledTableViewCell")
        self.tableView.register(UINib(nibName: "TextAreaTableViewCell", bundle: nil), forCellReuseIdentifier: "TextAreaTableViewCell")
        self.tableView.register(UINib(nibName: "ProfilImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfilImageTableViewCell")
        self.tableView.register(UINib(nibName: "imageProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "imageProfileTableViewCell")
        self.tableView?.register(UINib(nibName: "UserDetailInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailInfoTableViewCell")
        
        self.tableView.register(UINib(nibName: "DetePickerViewCell", bundle: nil), forCellReuseIdentifier: "DetePickerViewCell")

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        
        editButton.setTitleColor(UIColor.white, for: .normal)
        
        let presenter = ProfileEditPresenter(view: self)
        inject(presenter: presenter)
        presenter.apiUserInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "プロフィール更新"
        pickerView.delegate   = self
        pickerView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if presenter.data.count == 0 {
            return 0
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 || section == 3 {
            return 1
        } else if section == 2 {
            return 7
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 3){
            return "自己紹介"
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileCell")

        var myData = presenter.data[0]
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilImageTableViewCell") as! ProfilImageTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if (myData != nil) {
            //メイン画像
                if (self.image_main_param.size.width != 0) {
                    cell.mainImage.image = self.image_main_param
                } else if (myData.profile_image[0].id != nil) {
                    let profileImageURL = image_url  + myData.profile_image[0].path!
                    cell.mainImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                }
            } else {
                cell.mainImage.image = UIImage(named: "no_image")
            }
            cell.mainImage.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTapMainImage(_:)))
            recognizer.targetString = "0"
            cell.mainImage.addGestureRecognizer(recognizer)

            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageProfileTableViewCell") as! imageProfileTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            //サブ1画像
            if (myData != nil) {
                if (self.image_1_param.size.width != 0) {
                    cell.image_1.image = self.image_1_param
                } else if (myData.profile_image[1].id != nil) {
                    let profileImageURL = image_url + myData.profile_image[1].path!
                    cell.image_1.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                } else {
                    cell.image_1.image = UIImage(named: "add_image")
                }
            } else {
                cell.image_1.image = UIImage(named: "add_image")
            }
            cell.image_1.isUserInteractionEnabled = true
            var recognizer_1 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage_1(_:)))
            recognizer_1.targetString = "1"
            cell.image_1.addGestureRecognizer(recognizer_1)

            //サブ2画像
            if (myData != nil) {
                if (self.image_2_param.size.width != 0) {
                    cell.image_2.image = self.image_2_param
                } else if (myData.profile_image[2].id != nil) {
                    let profileImageURL = image_url + myData.profile_image[2].path!
                    cell.image_2.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                } else {
                    cell.image_2.image = UIImage(named: "add_image")
                }
            } else {
                cell.image_2.image = UIImage(named: "add_image")
            }
            cell.image_2.isUserInteractionEnabled = true
            var recognizer_2 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage_2(_:)))
            recognizer_2.targetString = "2"
            cell.image_2.addGestureRecognizer(recognizer_2)

            //サブ3画像
            if (myData != nil) {
                if (self.image_3_param.size.width != 0) {
                    cell.image_3.image = self.image_3_param
                } else if (myData.profile_image[3].id != nil) {
                    let profileImageURL = image_url + myData.profile_image[3].path!
                    cell.image_3.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                } else {
                    cell.image_3.image = UIImage(named: "add_image")
                }
            } else {
                cell.image_3.image = UIImage(named: "add_image")
            }
            cell.image_3.isUserInteractionEnabled = true
            var recognizer_3 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage_3(_:)))
            recognizer_3.targetString = "3"
            cell.image_3.addGestureRecognizer(recognizer_3)

            //サブ4画像
            if (myData != nil) {
                if (self.image_4_param.size.width != 0) {
                    cell.image_4.image = self.image_4_param
                } else if (myData.profile_image[4].id != nil) {
                    let profileImageURL = image_url + myData.profile_image[4].path!
                    cell.image_4.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
                } else {
                    cell.image_4.image = UIImage(named: "add_image")
                }
            } else {
                cell.image_4.image = UIImage(named: "add_image")
            }
            cell.image_4.isUserInteractionEnabled = true
            var recognizer_4 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage_4(_:)))
            recognizer_4.targetString = "4"
            cell.image_4.addGestureRecognizer(recognizer_4)
            return cell
        }

        if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                self.select_pcker_list[indexPath.row] = myData.sex ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                let attrText = NSMutableAttributedString(string: "※ ニックネーム ")
                attrText.addAttribute(.foregroundColor,value: UIColor.red, range: NSMakeRange(0, 1))
                cell.title?.attributedText = attrText
                cell.detail?.text = myData.name
                self.nick_name = myData.name ?? ""
                return cell
            }

            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                self.select_pcker_list[indexPath.row] = myData.sex ?? 0
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
                
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy/MM/dd"
                let date = dateFormater.date(from: presenter.data[0].birthday ?? "2000-01-01")
                cell.datePickerView.date = date!
                
                return cell
                

            }
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                self.select_pcker_list[indexPath.row] = myData.fitness_parts_id ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "痩せたい箇所"
                cell.detail?.text = ApiConfig.FITNESS_LIST[myData.fitness_parts_id ?? 0]
                return cell
            }

            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                self.select_pcker_list[indexPath.row] = myData.prefecture_id ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "居住地"
                cell.detail?.text = ApiConfig.PREFECTURE_LIST[myData.prefecture_id ?? 0]
                return cell
            }

            if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                self.select_pcker_list[indexPath.row] = myData.blood_type ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "血液型"
                cell.detail?.text = ApiConfig.BLOOD_LIST[myData.blood_type ?? 0]
                return cell
            }

            if indexPath.row == 6 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditTableViewCell") as! ProfileEditTableViewCell
                self.select_pcker_list[indexPath.row] = myData.work ?? 0
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.title?.text = "職業"
                cell.detail?.text = ApiConfig.WORK_LIST[myData.work ?? 0]
                return cell
            }
        }

        if indexPath.section == 3 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "userDetailInfo")
            cell.textLabel!.numberOfLines = 0
            cell.backgroundColor =  UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            if myData != nil {
                if (myData.profile_text == "") {
                    cell.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
                    cell.textLabel!.text = "自己紹介の入力はありません。"
                    cell.textLabel!.textColor = #colorLiteral(red: 0.572501719, green: 0.5725748539, blue: 0.5724850297, alpha: 1)
                } else {
                    cell.textLabel!.textColor = .popoTextColor
                    self.profile_text = myData.profile_text as! String
                    cell.textLabel!.text = myData.profile_text as! String
                }
            }
            return cell
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 110
        }
        if indexPath.section == 2 {
            return 50
        }
        if indexPath.section == 3 {
            tableView.estimatedRowHeight = 200 //セルの高さ
            return UITableView.automaticDimension //自動設定
        }
        return 370
     }
    
    @objc func onTapMainImage(_ sender: MyTapGestureRecognizer) {
        self.image_type = sender.targetString!
        selectImage(image_type: image_type)
    }

    @objc func onTapImage_1(_ sender: MyTapGestureRecognizer) {
        self.image_type = sender.targetString!
        selectImage(image_type: image_type)
    }
    @objc func onTapImage_2(_ sender: MyTapGestureRecognizer) {
        self.image_type = sender.targetString!
        selectImage(image_type: image_type)
    }
    @objc func onTapImage_3(_ sender: MyTapGestureRecognizer) {
        self.image_type = sender.targetString!
        selectImage(image_type: image_type)
    }
    @objc func onTapImage_4(_ sender: MyTapGestureRecognizer) {
        self.image_type = sender.targetString!
        selectImage(image_type: image_type)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickerView.selectRow(0, inComponent: 0, animated: false)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                selectImage(image_type: "11")
            }
        }

        if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.top_status = 1
                performSegue(withIdentifier: "profile_text", sender: self)
                dismissPicker()
            }
            if indexPath.row == 3 {
                self.selectPicker = 3
                self.pcker_list = ApiConfig.FITNESS_LIST
                self.selectRow = presenter.data[0].fitness_parts_id ?? 0
            }
            if indexPath.row == 4 {
                self.selectPicker = 4
                self.pcker_list = ApiConfig.PREFECTURE_LIST
                self.selectRow = presenter.data[0].prefecture_id ?? 0
            }
            if indexPath.row == 5 {
                self.selectPicker = 5
                self.pcker_list = ApiConfig.BLOOD_LIST
                self.selectRow = presenter.data[0].blood_type ?? 0
            }
            if indexPath.row == 6 {
                self.selectPicker = 6
                self.pcker_list = ApiConfig.WORK_LIST
                self.selectRow = presenter.data[0].work ?? 0
            }
            if indexPath.row != 0 {
                self.pickerView.selectRow(self.selectRow, inComponent: 0, animated: false)
                PickerPush()
            }
        }
        
        if indexPath.section == 3 {
            self.top_status = 2
            performSegue(withIdentifier: "profile_text", sender: self)
        }
            
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "profile_text" {
            
            if top_status == 1 {
                let vc:ProfileTextViewController = segue.destination as! ProfileTextViewController
                vc.name_1 = self.nick_name
                vc.status = self.top_status
                vc.closure_name = { [self](name_1: String) -> Void in
                    presenter.data[0].name = name_1
                    self.tableView.reloadData()
                }
            } else if top_status == 2 {
                let vc:ProfileTextViewController = segue.destination as! ProfileTextViewController
                vc.profile_text_1 = self.profile_text
                vc.status = self.top_status
                vc.closure_profile = { [self](profile_text_1: String) -> Void in
                    presenter.data[0].profile_text = profile_text_1
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                return nil
            } else {
                return indexPath
            }
        } else {
            return indexPath
        }
    }
    
    @IBAction func pickerSelectButton(_ sender: Any) {
        print("セレクトピッカー")
        if self.selectPicker == 3 {
            presenter.data[0].fitness_parts_id = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 4 {
            presenter.data[0].prefecture_id = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 5 {
            presenter.data[0].blood_type = self.select_pcker_list[self.selectPicker] ?? 0
        }
        if self.selectPicker == 6 {
            presenter.data[0].work = self.select_pcker_list[self.selectPicker] ?? 0
        }
        dismissPicker()
        tableView.reloadData()
        self.vi.removeFromSuperview()
    }

    @IBAction func pickerCloseButton(_ sender: Any) {
        dismissPicker()
    }
    
    func PickerPush(){
        print("きてる？？？")
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5,animations: {
            if UIScreen.main.nativeBounds.height >= 1792 {
                self.pickerBottom.constant = -280
            } else {
                self.pickerBottom.constant = -260
            }
            self.pickerView.updateConstraints()
            self.pickerView.reloadInputViews()
            self.tableView.updateConstraints()
            self.view.layoutIfNeeded()
        })
    }
    
    func dismissPicker(){
        UIView.animate(withDuration: 0.5,animations: {
            self.pickerBottom.constant = 300
            self.pickerView.updateConstraints()
            self.pickerView.reloadInputViews()
            self.tableView.updateConstraints()
            self.view.layoutIfNeeded()
        })
    }
    
    func detePickerSelect(date: String) {
        presenter.data[0].birthday = date
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectTextFild = 1
    }

    @objc func onClickCommitButton (sender: UIButton) {
        if(myTextView.isFirstResponder){
            myTextView.resignFirstResponder()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var tag = textField.tag
        presenter.data[0].name = textField.text!
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        presenter.data[0].name = textField.text!
        textField.resignFirstResponder()
        return
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        presenter.data[0].name = textField.text!
        textField.resignFirstResponder()
        return true
    }
    
    func validator(_ status: Int){
        self.activityIndicatorView.stopAnimating()
        // アラート作成
        var message = ""
        if status == 2 || status == 3 {
            if status == 2 {
                message = "ニックネームは15文字までになります"
            } else if status == 3 {
                message = "自己紹介は400文字までになります"
            }
            let alert = UIAlertController(title: "入力して下さい", message: message, preferredStyle: .alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // アラート表示
            self.present(alert, animated: true, completion: {
                // アラートを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            })
        } else {
            let alert = UIAlertController(title: "※は必須項目になります", message: "選択されていない項目があります", preferredStyle: .alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // アラート表示
            self.present(alert, animated: true, completion: {
                // アラートを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    @IBAction func editProfilButton(_ sender: Any) {
        
        if presenter.data.count == 0 {
            return
        }
        
        if presenter.data[0].name!.count > 15 {
            validator(2)
            return
        }
        if presenter.data[0].profile_text!.count > 400 {
            validator(3)
            return
        }

        if presenter.data[0].sex == 0 {
            validator(1)
            return
        }
        //パラメーター
        var query = [
            "id": presenter.data[0].id ?? 0,
            "name": presenter.data[0].name,
            "birthday": presenter.data[0].birthday,
            "work": presenter.data[0].work ?? 0,
            "sex": presenter.data[0].sex ?? 0,
            "fitness_parts_id": presenter.data[0].fitness_parts_id ?? 0,
            "blood_type": presenter.data[0].blood_type ?? 0,
            "prefecture_id": presenter.data[0].prefecture_id ?? 0,
            "edit": "1",
            "delete_image": self.delete_str,
            "profile_text": presenter.data[0].profile_text ?? "",
            "image_main": self.image_main,
            "image_1": self.image_1,
            "image_2": self.image_2,
            "image_3": self.image_3,
            "image_4": self.image_4,
        ] as! [String:Any]

        //リクエスト実行
        presenter.apiUpdate(query)
    }
    
    
    private func selectImage(image_type : String) {
        let alertController: UIAlertController = UIAlertController(title:  "カメラへアクセス", message: "登録に必要な写真に使用する為、お使いの機能をお選び下さい。", preferredStyle:  UIAlertController.Style.alert)
        //        let alertController = UIAlertController(title: "画像を選択", message: nil, preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "ライブラリから選択", style: .default) { (UIAlertAction) -> Void in
            self.selectFromLibrary()
        }
        let cameraAction = UIAlertAction(title: "カメラを起動", style: .default) { (UIAlertAction) -> Void in
            self.selectFromCamera()
        }
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { [self] (UIAlertAction) -> Void in
            //self.selectFromLibrary()
            self.delete_str = self.delete_str + presenter.data[0].profile_image[Int(image_type)!].path! + ","
            presenter.data[0].profile_image[Int(image_type)!].id = nil
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (UIAlertAction) -> Void in
            print("閉じる")
        }
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
    
        if (presenter.data[0].profile_image[Int(image_type)!].id != nil && image_type != "0") {
            alertController.addAction(deleteAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func selectFromCamera() {
        print("カメラ許可")
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
        let jpegCompressionQuality: CGFloat = 0.9 // Set this to whatever suits your purpose
        self.base64String = (resizedImage.jpegData(compressionQuality: jpegCompressionQuality)?.base64EncodedString())!
        
        if (self.image_type == "0") {
            self.image_main_param = resizedImage
            self.image_main = self.base64String
        }
        else if (self.image_type == "1") {
            self.image_1_param = resizedImage
            self.image_1 = self.base64String
        } else if (self.image_type == "2") {
            self.image_2_param = resizedImage
            self.image_2 = self.base64String
        } else if (self.image_type == "3") {
            self.image_3_param = resizedImage
            self.image_3 = self.base64String
        } else if (self.image_type == "4") {
            self.image_4_param = resizedImage
            self.image_4 = self.base64String
        }

        if (presenter.data[0].profile_image[Int(self.image_type)!].id != nil ) {
            self.delete_str = self.delete_str + presenter.data[0].profile_image[Int(image_type)!].path! + ","
        }

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
}

extension ProfileEditViewController: ProfileEditOutput {
    func update(_ type: String) {
        if type == "update" {
            let alertController:UIAlertController =
                UIAlertController(title:"プロフィールが更新されました",message: "プロフィールが更新されました",preferredStyle: .alert)
            let backView = alertController.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // Default のaction
            let defaultAction:UIAlertAction =
                UIAlertAction(title: "更新されました",style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                    self.activityIndicatorView.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                })
            // Cancel のaction
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "閉じる",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                    // 処理
                    print("キャンセル")
                    self.activityIndicatorView.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                })
            
            cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
            defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
            // actionを追加
            alertController.addAction(cancelAction)
            alertController.addAction(defaultAction)
            // UIAlertControllerの起動
            present(alertController, animated: true, completion: nil)
        } else {
            self.image_1_param = UIImage()
            self.image_2_param = UIImage()
            self.image_3_param = UIImage()
            self.image_4_param = UIImage()
            tableView.reloadData()
        }
    }
    
    func error() {
        //
    }
}

extension ProfileEditViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
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

}
