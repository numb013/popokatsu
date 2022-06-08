//
//  GroupChatViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

class GroupChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    let userDefaults = UserDefaults.standard
    let dateFormater = DateFormatter()
    @IBOutlet weak var sendButton: UIButton!
    var cellCount: Int = 0
    var dataSource = [ApiGroupChatList]()
    var dataSourceOrder: Array<String> = []
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var page_no = 1
    var isLoading:Bool = false
    var validate = 0
    var isUpdate:Bool = false
    var status = Int()
    var group_id:String = ""
    var comment:String = ""
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var activityIndicatorView = UIActivityIndicatorView()
    var selectRow = 0
    var keybord_status = 0
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textFiled.delegate = self

        self.tableView.register(UINib(nibName: "GroupChatTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChatTableViewCell")

        self.tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        navigationController!.navigationBar.topItem!.title = ""
        tabBarController?.tabBar.isHidden = true
            //フォアグランド
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(GroupChatViewController.viewWillEnterForeground(_:)),
//            name: UIApplication.willEnterForegroundNotification,
//            object: nil)
        //バックグランド
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GroupChatViewController.viewDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        if status == 3 {
            textFiled.isEnabled = false
            sendButton.isEnabled = false
            sendButton.backgroundColor =  #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            sendButton.setTitle("終了", for: .normal)
        }
        sendButton.layer.cornerRadius = 5.0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(self.refreshControl)
        self.navigationItem.title = "チャット"
        apiRequest()
    }
    
    @objc func refreshTable() {
        self.isLoading = true
        self.page_no = 1
        self.dataSourceOrder = []
        var dataSource: Dictionary<String, ApiGroupChatList> = [:]
        apiRequest()
        self.refreshControl?.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!self.isUpdate && scrollView.contentOffset.y  < -67.5) {
            self.isUpdate = true
            apiRequest()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //タブバー表示
//        tabBarController?.tabBar.isHidden = false
        self.isLoading = true
        self.page_no = 1
        self.dataSourceOrder = []
        var dataSource: Dictionary<String, ApiUserDate> = [:]
        var errorData: Dictionary<String, ApiErrorAlert> = [:]

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
        apiRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func viewDidEnterBackground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            self.textFieldShouldReturn(self.textFiled)
        }
    }

    func apiRequest() {
        let parameters = [
            "group_id": group_id,
            "page_no": self.page_no
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.createTweet, parameters: parameters,success: { [self] (response: [ApiGroupChatList]) in
            isUpdate = response.count < 5 ? false : true
            dataSource.append(contentsOf: response)
            textFiled.text = ""
            self.comment = ""

            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "設定"
//    }
    
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
        var myData = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatTableViewCell") as! GroupChatTableViewCell
        cell.comment?.text = myData.comment
        cell.name?.text = myData.name

        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = dateFormater.date(from: (myData.created_at!))
        dateFormater.dateFormat = "MM/dd HH:mm"
        let date_text = dateFormater.string(from: date ?? Date())
        cell.created_at?.text = String(date_text)
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.comment?.adjustsFontSizeToFitWidth = true
        cell.comment?.numberOfLines = 0

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200 //セルの高さ
        return UITableView.automaticDimension //自動設定
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var tag = textField.tag
        if tag == 0 {
            self.comment = textField.text!
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        if tag == 0 {
            self.comment = textField.text!
        }
        textField.resignFirstResponder()
        return
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.keybord_status = 0
        // キーボードを閉じる
        self.comment = textField.text!
        textField.resignFirstResponder()
        sendButton.isEnabled = true
        return true
    }

    func validator(_ status:Int){
        self.activityIndicatorView.stopAnimating()
        // アラート作成
        let alert = UIAlertController(title: "入力して下さい", message: "メッセージを入力してください。", preferredStyle: .alert)
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
        
    
    
    @IBAction func sendGroupChat(_ sender: Any) {

        activityIndicatorView.startAnimating()
        textFiled.endEditing(true)
        sendButton.isEnabled = false
        
//        let requestGroupChatModel = GroupChatModel();
//        requestGroupChatModel.delegate = self as! GroupChatModelDelegate;
//        //リクエスト先
//        let requestUrl: String = ApiConfig.REQUEST_URL_API_ADD_GROUP_CHAT;
//        //パラメーター
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        query["group_id"] = group_id
//        query["comment"] = self.comment
//
//        if (query["comment"] == "") {
//            self.validate = 1
//            validator()
//        }
//        if (self.validate == 0) {
//            //リクエスト実行
//            if( !requestGroupChatModel.requestApi(url: requestUrl, addQuery: query) ){
//            }
//        }

        let parameters = [
            "group_id": group_id,
            "comment": self.comment
        ] as [String:Any]
        
        if (parameters["comment"] as! String == "") {
            validator(1)
            return
        }
        
        API.requestHttp(POPOAPI.base.createGroup, parameters: parameters,success: { [self] (response: ApiStatus) in
                apiRequest()
            },
            failure: { [self] error in
                print(error)
            }
        )

    }
}
