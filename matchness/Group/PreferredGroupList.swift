//
//  PreferredGroupList.swift
//  matchness
//
//  Created by user on 2019/07/22.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import DZNEmptyDataSet

class PreferredGroupList: UIViewController, UITableViewDelegate , UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var decisionButton: UIButton!
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var dataSource = [ApiGroupRequest]()
    var dataGroupRequest = [ApiGroupRequestList]()

    var errorData: Dictionary<String, ApiErrorAlert> = [:]

    var GroupEventDeleteItem: UIBarButtonItem!
    var group_id: Int = Int()
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.allowsSelection = false
        
        self.tableView.register(UINib(nibName: "PreferredGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "PreferredGroupTableViewCell")
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)

        decisionButton.isEnabled = false // ボタン無効
        decisionButton.backgroundColor = .popoPinkOff
        GroupEventDeleteItem = UIBarButtonItem(title: "削除", style: .done, target: self, action: #selector(GroupEventDelete(_:)))
        self.navigationItem.rightBarButtonItems = [GroupEventDeleteItem]
        navigationController!.navigationBar.topItem!.title = ""
        apiRequest()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset.bottom = 100
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "グループ"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataGroupRequest.count
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "まだ参加希望者はいません", attributes:stringAttributes)
    }
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.dataSource[0].decision_type == 1) {
            decisionButton.isEnabled = true // ボタン有効
            decisionButton.backgroundColor = .popoPink
        } else {
            decisionButton.isEnabled = false // ボタン無効
            decisionButton.backgroundColor = .popoPinkOff
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferredGroupTableViewCell") as! PreferredGroupTableViewCell
        var requestGroup = self.dataSource[0].request_list![indexPath.row]

        cell.titel.text = requestGroup.name
        cell.period.text = "\(requestGroup.age!) 歳"
        if (requestGroup.status == 1) {
            cell.joinButton.setTitle("選択する", for: .normal)
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.targetString = "1"
            recognizer.targetUserId = requestGroup.user_id
            cell.joinButton.layer.backgroundColor = #colorLiteral(red: 0.007505211513, green: 0.569126904, blue: 0.5776273608, alpha: 1)
            cell.joinButton.addGestureRecognizer(recognizer)
        } else if (requestGroup.status == 2) {
            cell.joinButton.setTitle("選択中", for: .normal)
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.targetString = "2"
            recognizer.targetUserId = requestGroup.user_id
            cell.joinButton.layer.backgroundColor = #colorLiteral(red: 1, green: 0.6352941176, blue: 0, alpha: 1)
            cell.joinButton.addGestureRecognizer(recognizer)
        }
        cell.joinButton.layer.cornerRadius = 5.0 //丸みを数値で変更できます

        if (requestGroup.profile_image == nil) {
            cell.groupTestImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + (requestGroup.profile_image!)
            cell.groupTestImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }

        cell.groupTestImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTapImage(_:)))
        recognizer.targetUserId = requestGroup.user_id
        cell.groupTestImage.addGestureRecognizer(recognizer)

        return cell
    }

    @objc func onTapImage(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var tap_number = sender.targetString!
        var user_id = sender.targetUserId!

        if (tap_number == "1"){
            if (self.dataSource[0].decision_type == 0) {
                self.requestJoin(status:"2", user_id:user_id)
            } else {
                let alert = UIAlertController(title: "参加人数オーバー", message: "選択人数が参加人数より多くなります、選択しているユーザーをキャンセルする必要があります", preferredStyle: .alert)
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
        } else if (tap_number == "2"){
            self.requestJoin(status:"1", user_id:user_id)
        }
    }

    // "編集"ボタンが押された時の処理
    @objc func GroupEventDelete(_ sender: UIBarButtonItem) {
        let alertController:UIAlertController =
            UIAlertController(title:"本当に削除してよろしいですか",message: "作成時に使用したポイントは戻りません"  ,preferredStyle: .alert)
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // Default のaction
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "削除",style: .destructive,handler:{
                (action:UIAlertAction!) -> Void in
                self.activityIndicatorView.startAnimating()
                DispatchQueue.global(qos: .default).async {
                    // 非同期処理などを実行
                    Thread.sleep(forTimeInterval: 5)
                    // 非同期処理などが終了したらメインスレッドでアニメーション終了
                    DispatchQueue.main.async {
                        // アニメーション終了
                        self.requestDeleteGroup(group_id:self.group_id)
                    }
                }
            })

        // Cancel のaction
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                (action:UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
        cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
        defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
//        // UIAlertControllerの起動
        self.present(alertController, animated: true, completion: nil)
//        self.requestDeleteGroup(group_id:group_id)
    }
    

    @IBAction func decisionAction(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionChoise1 = UIAlertAction(title: "今日から始める", style: .default){
            action in
            self.eventStart(1)
        }
        let actionChoise2 = UIAlertAction(title: "翌日から始める", style: .default){
            action in
            self.eventStart(2)
        }
        let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel){
            (action) -> Void in
        }
        // actionを追加
        alertController.addAction(actionChoise1)
        alertController.addAction(actionChoise2)
        alertController.addAction(actionCancel)
        // UIAlertControllerの起動
        present(alertController, animated: true, completion: nil)
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setteing_status:[String:Any] = ["status":"2", "indexPath":indexPath]
        self.performSegue(withIdentifier: "toGroupEvent", sender: setteing_status)
    }

    func startAlert(status:Int) {
        var message = "本日の0時からの歩数の集計でスタートしました。"
        if status == 2 {
            message = "翌日の0時からの歩数の集計でスタートします。"
        }
        // アラート作成
        let alert = UIAlertController(title: "グループの開催を受け付けました", message: message, preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                alert.dismiss(animated: true, completion: nil)
                let layere_number = self.navigationController!.viewControllers.count
                self.navigationController?.popToViewController(self.navigationController!.viewControllers[layere_number-2], animated: true)

            })
        })
    }
    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "group_id" : self.group_id
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectRequestGroupEvent, parameters: parameters,success: { [self] (response: [ApiGroupRequest]) in

            dataSource = response
            dataGroupRequest = dataSource[0].request_list!
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )

    }
    
    func requestJoin(status: String, user_id: Int) {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "user_id": user_id,
            "group_id": self.group_id,
            "status": status,
            "type": 2
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.requestGroupEvent, parameters: parameters,success: { [self] (response: [ApiGroupRequest]) in
            dataSource = response
            dataGroupRequest = dataSource[0].request_list!
            
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    func eventStart(_ status:Int) {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "group_id": self.group_id,
            "start_status": status
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.groupEventStart, parameters: parameters,success: { [self] (response: ApiStatus) in
                self.startAlert(status:status)
            },
            failure: { [self] error in
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "設定", message: "失敗しました。", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = .white
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )
    }
    
    func requestDeleteGroup(group_id: Int) {
        let parameters = [
            "group_id": group_id
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.recruitmentDeleteGroup, parameters: parameters,success: { [self] (response: ApiStatus) in
            self.activityIndicatorView.stopAnimating()
            self.navigationController?.popViewController(animated: true)
            },
            failure: { [self] error in
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "設定", message: "失敗しました。", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = .white
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )
    }
    
    
}
