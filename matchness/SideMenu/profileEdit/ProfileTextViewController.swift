//
//  ProfileTextViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/07/09.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit

class ProfileTextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {

    var myTextView = UITextView()
    @IBOutlet weak var tableView: UITableView!
    var status = 0
    var profile_text_1 = ""
    var name_1 = ""

    @IBOutlet weak var titleLabel: UILabel!
    
    var closure_name: ((String) -> Void)?
    var closure_profile: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        myTextView.delegate = self
        
        self.tableView.register(UINib(nibName: "TextFiledTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFiledTableViewCell")
        
        self.tableView.register(UINib(nibName: "ProfileEditTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileEditTableViewCell")
        
        self.navigationItem.title = "自己紹介入力"
//        navigationController!.navigationBar.topItem!.title = ""
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.status == 1 {
            self.navigationItem.title = "ニックネーム"
            titleLabel.text = "ニックネーム入力"
        } else if self.status == 2 {
            self.navigationItem.title = "自己紹介入力"
            titleLabel.text = "自己紹介入力"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileTextCell")
        if self.status == 1 {
                if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFiledTableViewCell") as! TextFiledTableViewCell
                cell.title?.text = "ニックネーム入力"
                cell.textFiled.delegate = self
                cell.textFiled?.text = self.name_1
                cell.textFiled.placeholder = "※15文字まで"
                cell.selectionStyle = .none
                    
                return cell
            }
        } else if self.status == 2 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileTextCell")

            if indexPath.row == 0 {
                myTextView.text = self.profile_text_1
                let width1 = self.view.frame.width - 20
                myTextView.frame = CGRect(x:((self.view.bounds.width-width1)/2),y:75, width:width1,height:250)
                myTextView.layer.masksToBounds = true
                myTextView.layer.cornerRadius = 3.0
                myTextView.layer.borderWidth = 1
                myTextView.layer.borderColor =  #colorLiteral(red: 0.7948118448, green: 0.7900883555, blue: 0.7984435558, alpha: 1)
                myTextView.textAlignment = NSTextAlignment.left
                myTextView.font = UIFont.systemFont(ofSize: 17)

                let custombar = UIView(frame: CGRect(x:0, y:0,width:(UIScreen.main.bounds.size.width),height:40))
                custombar.backgroundColor = UIColor.groupTableViewBackground
                let commitBtn = UIButton(frame: CGRect(x:(UIScreen.main.bounds.size.width)-80,y:0,width:80,height:40))
                commitBtn.setTitle("閉じる", for: .normal)
                commitBtn.setTitleColor(UIColor.blue, for:.normal)
                commitBtn.addTarget(self, action:#selector(ProfileEditViewController.onClickCommitButton), for: .touchUpInside)
                custombar.addSubview(commitBtn)
                myTextView.inputAccessoryView = custombar
                myTextView.keyboardType = .default
                myTextView.isEditable = true
                myTextView.isSelectable = true

                cell.selectionStyle = .none
//                cell.addSubview(myTextView)
                self.view.addSubview(myTextView)
                return cell
            }
        }
        if indexPath.row == 1 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "profileTextCell")
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.status == 1 {
            return 60
        } else if self.status == 2 {
            return 280
        }
        return 100
     }
    
    func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var tag = textView.tag
        self.profile_text_1 = textView.text!
        tableView.reloadData()
        return true
    }
    
    //編集終了後のtextデータを、別のファイルへ送信したい時はこの中に書く。
    func textViewDidChange(_ textView: UITextView) {
        self.profile_text_1 = myTextView.text
    }
    
    @objc func onClickCommitButton (sender: UIButton) {
        if(myTextView.isFirstResponder){
            myTextView.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        self.name_1 = textField.text!
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField:UITextField){
        self.name_1 = textField.text!
    }
    
    @IBAction func compButton(_ sender: Any) {
        if self.status == 1 {
            closure_name?(self.name_1) //値を受け渡す
        } else if self.status == 2 {
            closure_profile?(self.profile_text_1) //値を受け渡す
        }
        dismiss(animated: true, completion: nil)
    }
}
