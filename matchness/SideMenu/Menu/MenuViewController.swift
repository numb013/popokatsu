//
//  accodionViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/11/09.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

class MenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var status = ""
    var notice_setting = ""
    var swich_status:Bool = true
    var cellCount: Int = 0
    var dataSource = [ApiSetting]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    private var requestAlamofire: Alamofire.Request?;
    var webType = ""
    var dataSourceOrder: Array<String> = []
//    var ActivityIndicator: UIActivityIndicatorView!
    var activityIndicatorView = UIActivityIndicatorView()
    
    private var sections: [Section] = [
        Section(title: "通知設定",values: [
        ],expanded: true),
        Section(title: "退会について",values: [
            ("退会についての説明", false),
            ("退会する", false),
        ],expanded: true),
        Section(title: "その他",values: [
            ("お問合せ", false),
            ("マニュアル", false),
            ("利用規約", false),
            ("プライバシーポリシー", false)
        ],expanded: true),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        setupTableView()
        
        view.backgroundColor = .white
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        //通知設定確認
        updateUI()

        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            // 非同期処理などを実行
            Thread.sleep(forTimeInterval: 5)
            // 非同期処理などが終了したらメインスレッドでアニメーション終了
            DispatchQueue.main.async {
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
            }
        }

        self.navigationItem.title = "設定"
//        navigationController!.navigationBar.topItem!.title = ""
        tabBarController?.tabBar.isHidden = true
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.contentInset.bottom = 100
        apiRequest()
    }
    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        API.requestHttp(POPOAPI.base.menuSelect, parameters: nil,success: { [self] (response: [ApiSetting]) in
                dataSource = response
                self.activityIndicatorView.stopAnimating()
                tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataSource.isEmpty == true {
            return 0
        }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if self.notice_setting == "1" {
                return 5
            } else {
                return 1
            }
        } else if (section == 1) {
            return 2
        }
        return 4
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mySetting = self.dataSource[0]
        if (indexPath.section == 0) {
            if self.notice_setting == "1" {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "myCell")
                let switchView = UISwitch()
                cell.accessoryView = switchView
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                if indexPath.row == 0 {
                    cell.textLabel?.text = "メッセージ通知"
                    if (mySetting.message_notice == 0) {
                        swich_status = false
                    } else {
                        swich_status = true
                    }
                    //スイッチの状態
                    switchView.isOn = swich_status
                    //タグの値にindexPath.rowを入れる。
                    switchView.tag = indexPath.row
                    //スイッチが押されたときの動作
                    switchView.addTarget(self, action: #selector(fundlSwitch(_:)), for: UIControl.Event.valueChanged)
                    return cell
                }
                if indexPath.row == 1 {
                    cell.textLabel?.text = "グループ通知"
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    if (mySetting.group_notice == 0) {
                        swich_status = false
                    } else {
                        swich_status = true
                    }
                    //スイッチの状態
                    switchView.isOn = swich_status
                    //タグの値にindexPath.rowを入れる。
                    switchView.tag = indexPath.row
                    //スイッチが押されたときの動作
                    switchView.addTarget(self, action: #selector(fundlSwitch(_:)), for: UIControl.Event.valueChanged)
                    return cell
                }
                if indexPath.row == 2 {
                    cell.textLabel?.text = "足跡通知"
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    if (mySetting.foot_notice == 0) {
                        swich_status = false
                    } else {
                        swich_status = true
                    }
                    //スイッチの状態
                    switchView.isOn = swich_status
                    //タグの値にindexPath.rowを入れる。
                    switchView.tag = indexPath.row
                    //スイッチが押されたときの動作
                    switchView.addTarget(self, action: #selector(fundlSwitch(_:)), for: UIControl.Event.valueChanged)
                    return cell
                }
                if indexPath.row == 3 {
                    cell.textLabel?.text = "いいね通知"
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    if (mySetting.like_notice == 0) {
                        swich_status = false
                    } else {
                        swich_status = true
                    }
                    //スイッチの状態
                    switchView.isOn = swich_status
                    //タグの値にindexPath.rowを入れる。
                    switchView.tag = indexPath.row
                    //スイッチが押されたときの動作
                    switchView.addTarget(self, action: #selector(fundlSwitch(_:)), for: UIControl.Event.valueChanged)
                    return cell
                }
                if indexPath.row == 4 {
                    cell.textLabel?.text = "マッチング通知"
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    if (mySetting.match_notice == 0) {
                        swich_status = false
                    } else {
                        swich_status = true
                    }
                    //スイッチの状態
                    switchView.isOn = swich_status
                    //タグの値にindexPath.rowを入れる。
                    switchView.tag = indexPath.row
                    //スイッチが押されたときの動作
                    switchView.addTarget(self, action: #selector(fundlSwitch(_:)), for: UIControl.Event.valueChanged)
                    return cell
                }
            } else if self.notice_setting == "0" {
                if indexPath.row == 0 {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: "myCell")
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                    cell.textLabel!.text = "通知オンに設定する"
                    return cell
                }
            }
        }
        if (indexPath.section == 1) {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "myCell")
            if indexPath.row == 0 {
                cell.textLabel?.text = sections[indexPath.section].values[indexPath.row].title
                return cell
            }
            if indexPath.row == 1 {
                cell.textLabel?.text = sections[indexPath.section].values[indexPath.row].title
                return cell
            }
        }
        if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuTableViewCell
            cell.titleLabel.numberOfLines=0
            cell.titleLabel.text = sections[indexPath.section].values[indexPath.row].title
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuTableViewCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && self.notice_setting == "1" {
            return
        }
        if (self.notice_setting == "0" && indexPath.section == 0 && indexPath.row == 0) {
            // OSの通知設定画面へ遷移
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 1) {
                let alertController:UIAlertController =
                    UIAlertController(title:"退会する",message: "本当に退会しますか？",preferredStyle: .alert)
                let backView = alertController.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 5.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                let defaultAction:UIAlertAction =
                    UIAlertAction(title: "退会する",style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                        self.userDeletApi()
                    })
                let cancelAction:UIAlertAction =
                    UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                    })
                cancelAction.setValue(#colorLiteral(red: 0, green: 0.71307832, blue: 0.7217405438, alpha: 1), forKey: "titleTextColor")
                defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
                alertController.addAction(cancelAction)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            } else {
                let webPage = ApiConfig.SITE_BASE_URL + "/delete"
                let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
                present(safariVC, animated: true, completion: nil)
            }
        } else {
            if (indexPath.row == 0) {
                if #available(iOS 13.0, *) {
                    let contactView = ContactViewController()
                    contactView.type = 1
                    navigationController?.pushViewController(contactView, animated: true)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                self.webType = String(indexPath.section) + String(indexPath.row)
                switch (webType) {
                case "21":
                    let webPage = ApiConfig.SITE_BASE_URL + "/menu"
                    let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
                    present(safariVC, animated: true, completion: nil)
                    break
                case "22":
                    let webPage = ApiConfig.SITE_BASE_URL + "/terms"
                    let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
                    present(safariVC, animated: true, completion: nil)
                    break
                case "23":
                    let webPage = ApiConfig.SITE_BASE_URL + "/privacy"
                    let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
                    present(safariVC, animated: true, completion: nil)
                    break
                default:
                    break
                }
            }
        }
    }
        
    //スイッチのテーブルが変更されたときに呼ばれる
    @objc func fundlSwitch(_ sender: UISwitch) {
        settingApi(sender.tag, sender.isOn)
    }

    func settingApi(_ status1:Int, _ status2:Bool) {
        if (status2 == false) {
            self.status = "0"
        } else {
            self.status = "1"
        }
        var parameters = [String:Any]()
        if (status1 == 0) {
            parameters["message_notice"] = self.status
        }
        if (status1 == 1) {
            parameters["group_notice"] = self.status
        }
        if (status1 == 2) {
            parameters["foot_notice"] = self.status
        }
        if (status1 == 3) {
            parameters["like_notice"] = self.status
        }
        if (status1 == 4) {
            parameters["match_notice"] = self.status
        }
        
        API.requestHttp(POPOAPI.base.menuEdit, parameters: parameters,success: { [self] (response: ApiStatus) in
                self.activityIndicatorView.stopAnimating()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func userDeletApi() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "status" : 0
        ] as! [String:Any]
        API.requestHttp(POPOAPI.base.userDelete, parameters: parameters,success: { [self] (response: ApiStatus) in
                self.activityIndicatorView.stopAnimating()
            },
            failure: { [self] error in
                print(error)
                //  リクエスト失敗 or キャンセル時
                let alert = UIAlertController(title: "退会", message: "退会に失敗しました。", preferredStyle: .alert)
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
        
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "fblogin") as! FBLoginViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        if sections[indexPath.section].expanded {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SectionHeaderView()
        headerView.config(title: sections[section].title, section: section) { [unowned self] section in
            self.sections[section].expanded = !self.sections[section].expanded
            self.tableView.beginUpdates()
            for i in 0 ..< self.sections[section].values.count {
                self.tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
            }
            self.tableView.endUpdates()
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }

    @IBAction func backFromMenuView(segue:UIStoryboardSegue){
        NSLog("ReportViewController#backFromMenuView")
    }

    func updateUI() {
        guard let types = UIApplication.shared.currentUserNotificationSettings?.types else {
            return
        }
        switch types {
        case [.badge, .alert]:
            self.notice_setting = "1"
        case [.badge]:
            self.notice_setting = "1"
        case []:
            self.notice_setting = "0"
        default:
            self.notice_setting = "1"
        }
    }
}
