//
//  PointPaymentViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/12/04.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import StoreKit

struct payParam: Codable {
    let status: String
}

class PointPaymentViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, PurchaseManagerDelegate {

    
//    var cellCount: Int = 0
//    var dataSource: Dictionary<String, ApiPaymentPointList> = [:]
//    var dataSourceOrder: Array<String> = []
//    var errorData: Dictionary<String, ApiErrorAlert> = [:]
//    private var requestAlamofire: Alamofire.Request?;
//    var cell_count = 0
//    var page_no = "1"
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [ApiPaymentPointList]()
    var activityIndicatorView = UIActivityIndicatorView()
    let userDefaults = UserDefaults.standard
    var pay_point = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "pointPaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "pointPaymentTableViewCell")
        self.tableView.register(UINib(nibName: "PointExplanationTableViewCell", bundle: nil), forCellReuseIdentifier: "PointExplanationTableViewCell")
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        self.navigationItem.title = "ポイント購入"
        navigationController!.navigationBar.topItem!.title = ""

        apiRequest()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "ポイント購入"
    }

    
    func apiRequest() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        API.requestHttp(POPOAPI.base.pointPayment, parameters: nil,success: { [self] (response: [ApiPaymentPointList]) in
                dataSource = response
                tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        if (indexPath.row + 1 == dataSource.count + 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PointExplanationTableViewCell") as! PointExplanationTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            if self.userDefaults.object(forKey: "sex")! as! Int == 1 {
                cell.pointExplanationImage?.image = UIImage(named: "pay_girl")
            } else {
                cell.pointExplanationImage?.image = UIImage(named: "pay_boy")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pointPaymentTableViewCell") as! pointPaymentTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

//            var point_pay = self.dataSource[indexPath.row]
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.amount.text = String(self.dataSource[indexPath.row].price!)
            cell.point.text = String(self.dataSource[indexPath.row].point!)

            if indexPath.row % 2 == 0 {
                cell.point.textColor = #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
                cell.unit.textColor = #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
            }
            cell.pointPaymentImage.image = UIImage(named: "paybuttom")
            cell.pointPaymentImage.isUserInteractionEnabled = true
            return cell
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row + 1 == self.dataSource.count + 1 {
            return 900
        }
        return 85
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        self.pay_point = self.dataSource[indexPath.row].point! as! String
        startPurchase(productIdentifier: (self.dataSource[indexPath.row].product_id!))
    }

    //------------------------------------
    // 課金処理開始
    //------------------------------------
    func startPurchase(productIdentifier : String) {
        print("課金処理開始!!")
        activityIndicatorView.startAnimating()
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier], completion: { (products, error) -> Void in
            if (products?.count)! > 0 {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print(error)
            }
        })
    }

    // リストア開始
    func startRestore() {
        print("リストア開始")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }

    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        // TODO UserDefault更新
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)

        apiPayRequest()
        self.activityIndicatorView.stopAnimating()
    }

    
    func apiPayRequest() {
        API.requestHttp(POPOAPI.base.pointComp, parameters: nil,success: { [self] (response:ApiStatus) in
                self.pay_point = ""
                if (response.status == "OK") {
                   let layere_number = self.navigationController!.viewControllers.count
                   self.navigationController?.popToViewController(self.navigationController!.viewControllers[layere_number-2], animated: true)
                }
            },
            failure: { [self] error in
                print(error)
                //  リクエスト失敗 or キャンセル時
                self.pay_point = ""
                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                return;
            }
        )


//        let requestUrl: String = ApiConfig.REQUEST_URL_API_PAY_COMP;
//        //パラメーター
//        var query: Dictionary<String,String> = Dictionary<String,String>();
//        query["point"] = self.pay_point
//        var headers: HTTPHeaders = [:]
//        var api_key = userDefaults.object(forKey: "api_token") as? String
//        if ((api_key) != nil) {
//            headers = [
//                "Accept" : "application/json",
//                "Authorization" : "Bearer " + api_key!,
//                "Content-Type" : "application/x-www-form-urlencoded"
//            ]
//        }
//
//        self.requestAlamofire = AF.request(requestUrl, method: .post, parameters: query, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
//            switch response.result {
//            case .success:
//                 guard let data = response.data else { return }
//                 guard let payParam = try? JSONDecoder().decode(payParam.self, from: data) else {
//                     return
//                 }
//                 self.pay_point = ""
//                 if (payParam.status == "OK") {
//                    let layere_number = self.navigationController!.viewControllers.count
//                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[layere_number-2], animated: true)
//                 }
//            case .failure:
//                //  リクエスト失敗 or キャンセル時
//                self.pay_point = ""
//                let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
//                let backView = alert.view.subviews.last?.subviews.last
//                backView?.layer.cornerRadius = 15.0
//                backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                self.present(alert, animated: true, completion: {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
//                        alert.dismiss(animated: true, completion: nil)
//                    })
//                })
//                return;
//            }
//        }
    }

    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }

    //課金失敗時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!) {
        print(NSError.self)
        print("課金失敗！！")
        self.activityIndicatorView.stopAnimating()
        // TODO errorを使ってアラート表示
        self.pay_point = ""
        let alert = UIAlertController(title: "購入処理失敗", message: "購入処理に失敗しました。", preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.present(alert, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }

    // リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!) {
        print("リストア終了！！")
        // TODO インジケータなどを表示していたら非表示に
    }

    // 承認待ち状態時に呼び出される(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!) {
        print("承認待ち！！")
        // TODO インジケータなどを表示していたら非表示に
    }
}
