//
//  ContactViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/01/31.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import Alamofire

@available(iOS 13.0, *)
class ContactViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate  {

    let userDefaults = UserDefaults.standard
    @IBOutlet var textViewPost: UITextView!
    @IBOutlet weak var ContactButton: UIButton!
    @IBOutlet weak var titile: UILabel!
    
    var report_param = [String:Any]()
    var type = Int()
    var message = String()
    var activityIndicatorView = UIActivityIndicatorView()
    private var placeholderLabel = UILabel()
    var validate = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewPost.delegate = self
        loadData()
    }

    // MARK: - Data methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadData() {
        if type == 1 {
            titile.text = "お問合せ"
            placeholderLabel.text = "お問合せ内容を入力してください"
            ContactButton.setTitle("お問合せする", for:UIControl.State.normal)
        } else {
            titile.text = "通報"
            placeholderLabel.text = "通報内容を入力してください"
            ContactButton.setTitle("通報する", for:UIControl.State.normal)
        }
        placeholderLabel.font = textViewPost.font
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: textViewPost.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor.quaternaryLabel
        placeholderLabel.isHidden = !textViewPost.text.isEmpty
        
        // 枠のカラー
        textViewPost.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        // 枠の幅
        textViewPost.layer.borderWidth = 1.0

        textViewPost.addSubview(placeholderLabel)
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        self.message = textViewPost.text!
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.message = textField.text!
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        self.message = textField.text!
        textField.resignFirstResponder()
        return
    }

    @objc func onClickCommitButton (sender: UIButton) {
        if(textViewPost.isFirstResponder){
            textViewPost.resignFirstResponder()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.message = textField.text!
        print(self.message)
        textField.resignFirstResponder()
        return true
    }

    @objc func actionCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func validator(_ status: Int){
        self.activityIndicatorView.stopAnimating()
        var alert = UIAlertController()
        // アラート作成
        if status == 1 {
            alert = UIAlertController(title: "お問合せエラー", message: "お問合せ内容を入力して下さい", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "通報エラー", message: "通報理由を入力して下さい", preferredStyle: .alert)
        }

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
    
    @IBAction func addButton(_ sender: Any) {
        //パラメーター
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        var requestUrl = "";
//        if type == 1 {
//            //リクエスト先
//            requestUrl = ApiConfig.REQUEST_URL_API_ADD_CONTACT;
//            query["message"] = self.message
//            if (query["message"] == "") {
//                self.validate = 1
//                validator()
//            }
//        } else {
//            //リクエスト先
//            requestUrl = ApiConfig.REQUEST_URL_API_ADD_REPORT;
//            query["target_id"] = report_param["target_id"] as! String
//            if report_param["type"] as! Int == 1 {
//                query["text"] = self.message + " by:ユーザー"
//            } else {
//                var tweet_id = report_param["tweet_id"]
//                query["text"] = self.message + " by:つぶやき id=" + "\(tweet_id)"
//            }
//        }

        var setAPIModule : APIModule = POPOAPI.base.createContact
        var parameters = [String:Any]()
        if type == 1 {
            parameters["message"] = self.message
            if (parameters["message"] as! String == "") {
                validator(1)
                return
            }
        } else {
            setAPIModule = POPOAPI.base.createReport
            parameters["target_id"] = report_param["target_id"] as! String
            if report_param["type"] as! Int == 1 {
                parameters["text"] = self.message + " by:ユーザー"
            } else {
                var tweet_id = report_param["tweet_id"]
                parameters["text"] = self.message + " by:つぶやき id=" + "\(tweet_id)"
            }
        }
        
        API.requestHttp(setAPIModule, parameters: parameters,success: { [self] (response: ApiStatus) in
            // アラート作成
            var message = "お問合せ完了しました";
            if self.type == 2 {
                message = "通報完了しました";
            }
            let alert = UIAlertController(title: message, message: "貴重なご意見ありがとうございます。", preferredStyle: .alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // アラート表示
            self.present(alert, animated: true, completion: {
                // アラートを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    alert.dismiss(animated: true, completion: nil)
//                    self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true)
                })
            })
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
}
