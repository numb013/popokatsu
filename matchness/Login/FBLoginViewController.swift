//
//  FBLoginViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/07/31.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON

struct noSnsloginParam: Codable {
    let id: Int
    let api_token: String
    let hash_id: String
    let is_user: Int
    let status: Int
    let sex: Int
}

@available(iOS 13.0, *)
class FBLoginViewController: UIViewController, UIViewControllerTransitioningDelegate {

    private var requestAlamofire: Alamofire.Request?;
    var userProfile : NSDictionary = [:]
    var login_sns_type = ""
    var sns_id = ""
    var name = ""
    var email = ""
    var status = 0
    let userDefaults = UserDefaults.standard
    let button = UIButton()
    var activityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var topImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        topImage?.image = UIImage(named: "login_top")
        // ログイン済みかチェック
//        checkloginFacebook()

        // ボタンのインスタンス生成
        
        button.setTitle("ユーザ登録", for:UIControl.State.normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //外枠の色を指定
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //外枠の太さを指定
        button.layer.borderWidth = 3.0
        // タップされたときのaction
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.create(_:)))
        button.addGestureRecognizer(recognizer)
        button.layer.cornerRadius = 5.0

        // ボタンのインスタンス生成
        let button_1 = UIButton()
        button_1.setTitle("SNSログインをご利用の方", for:UIControl.State.normal)
        button_1.titleLabel?.font =  UIFont.systemFont(ofSize: 18, weight: .bold)
        button_1.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        // タップされたときのaction
        var recognizer1 = MyTapGestureRecognizer(target: self, action: #selector(self.snsLogin(_:)))
        button_1.addGestureRecognizer(recognizer1)
        button_1.layer.cornerRadius = 5.0

        switch (UIScreen.main.nativeBounds.height) {
        case 1334:
            // iPhone 6
            // iPhone 6s
            // iPhone 7
            // iPhone 8
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:505,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:580,width:300,height:65)
            break
        case 1792:
            //iPhone XR
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:700,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:775,width:300,height:65)
            break
        case 1920:
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:560,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:635,width:300,height:65)
            break
        case 2208:
            // iPhone 6 Plus
            // iPhone 6s Plus
            // iPhone 7 Plus
            // iPhone 8 Plus
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:560,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:635,width:300,height:65)
            break
        case 2436:
            //iPhone X
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:635,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:710,width:300,height:65)
            break
        case 2688:
            //iPhone XR
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:710,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:785,width:300,height:65)
            break
        default:
            button.frame = CGRect(x:((self.view.bounds.width-300)/2),y:555,width:300,height:65)
            button_1.frame = CGRect(x:((self.view.bounds.width-300)/2),y:630,width:300,height:65)
            break
        }

        view.addSubview(button)
        view.addSubview(button_1)

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
    }

    @objc func create(_ sender: MyTapGestureRecognizer) {
        button.isEnabled = false
        activityIndicatorView.startAnimating()
        apiLoginCheck()
    }
    
    @objc func snsLogin(_ sender: MyTapGestureRecognizer) {
        //画面遷移
        let storyboard = UIStoryboard(name: "Modal", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "modal") as! LoginModalViewController

        modalVC.modalPresentationStyle = .custom
        modalVC.transitioningDelegate = self
        present(modalVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return LoginModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func updateView(type: Int) {
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        if type == 1 {
            let storyboard: UIStoryboard = self.storyboard!
            //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
            let multiple = storyboard.instantiateViewController(withIdentifier: "start")
            multiple.modalPresentationStyle = .fullScreen
            //ここが実際に移動するコードとなります
            self.present(multiple, animated: true, completion: nil)
        } else {
            //画面遷移
            self.performSegue(withIdentifier: "toProfileAdd", sender: self)
        }
    }

    func apiLoginCheck() {
        
        API.requestHttp(POPOAPI.base.noSNSAdd, parameters: nil,success: { [self] (response: noSnsloginParam) in
                self.activityIndicatorView.stopAnimating()
                self.status = response.status
                let userDefaults = UserDefaults.standard
                userDefaults.set(response.api_token, forKey: "api_token")
                //画面遷移
                self.performSegue(withIdentifier: "toProfileAdd", sender: self)
            },
            failure: { [self] error in
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "アクセスエラー", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return
            }
        )
        
        
        
        
//         let requestUrl: String = ApiConfig.REQUEST_URL_API_NO_SNS_USER_ADD;
//         //パラメーター
//         var query: Dictionary<String,String> = Dictionary<String,String>();
//         let headers: HTTPHeaders = [
//             "Accept" : "application/json",
//             "Authorization" : "",
//             "Content-Type" : "application/x-www-form-urlencoded"
//         ]
////         query["name"] = self.name
////         query["email"] = self.email
////         query["login_sns_type"] = self.login_sns_type
////         query["sns_id"] = self.sns_id
//         self.requestAlamofire = AF.request(requestUrl, method: .post, parameters: query, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
//               switch response.result {
//               case .success:
//                    guard let data = response.data else { return }
//                    guard let noSnsloginParam = try? JSONDecoder().decode(noSnsloginParam.self, from: data) else {
//                        print("取得失敗")
//                        self.activityIndicatorView.stopAnimating()
//                        return
//                    }
//                    self.activityIndicatorView.stopAnimating()
//                    self.status = noSnsloginParam.status
//                    let userDefaults = UserDefaults.standard
//                    userDefaults.set(noSnsloginParam.api_token, forKey: "api_token")
//                    //画面遷移
//                    self.performSegue(withIdentifier: "toProfileAdd", sender: self)
//               case .failure:
//                   //  リクエスト失敗 or キャンセル時
//                   let alert = UIAlertController(title: "アクセスエラー", message: "しばらくお待ちください", preferredStyle: .alert)
//                   let backView = alert.view.subviews.last?.subviews.last
//                   backView?.layer.cornerRadius = 15.0
//                   backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                   self.present(alert, animated: true, completion: {
//                       DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                           alert.dismiss(animated: true, completion: nil)
//                       })
//                   })
//               return;
//           }
//       }
    }
}
