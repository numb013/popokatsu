//
//  RouletteViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2022/02/08.
//  Copyright © 2022 a2c. All rights reserved.
//

import UIKit
import Charts
import GoogleMobileAds

import MessageUI
import CoreTelephony


class RouletteViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    private var interstitial: GADInterstitialAd?
    let userDefaults = UserDefaults.standard

    var buttonStartFlg = true
    // 現時点での回転角
    var currentDegree: CGFloat = 0
    // 定期割り込みのための Timer のインスタンス
    var timer = Timer()
    var interval: TimeInterval = 0.01
    
    var hitPoint:Double = 5
    var point = Int()
    var usePoint = 1000
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var yajirushi: UIImageView!
    // ボタン
    @IBOutlet weak var startButton: UIButton!
    // ルーレット画像
    @IBOutlet weak var pieChartsView: PieChartView!

    override func viewDidLoad() {
        self.point = self.userDefaults.object(forKey: "point") as! Int
        
        pieChartsView.usePercentValuesEnabled = true
        pieChartsView.legend.enabled = false
        pieChartsView.highlightPerTapEnabled = false
        pieChartsView.isUserInteractionEnabled = false
        
        if hitPoint == 5 {
            self.backView.backgroundColor = #colorLiteral(red: 0.8230579495, green: 0.6966378093, blue: 0.2210325897, alpha: 0.5)
        }
        if hitPoint == 10 {
            self.backView.backgroundColor = #colorLiteral(red: 0.6795967221, green: 0.6755590439, blue: 0.6827017665, alpha: 0.3)
        }
        if hitPoint == 15 {
            self.backView.backgroundColor = #colorLiteral(red: 0.6633054614, green: 0.4208735824, blue: 0.3299359679, alpha: 0.5033807818)
        }
        
        let values: [String] = ["AAAA", "BBBB"]
        let date : [Double] = [1,2]
        var entries: [ChartDataEntry] = [
            PieChartDataEntry(value: 100-hitPoint, label: "ハズレ"),
            PieChartDataEntry(value: hitPoint, label: "当たり")
        ]
        
//        for (i, value) in values.enumerated(){
//            entries.append(PieChartDataEntry(value: date[i], label: values[i]))
//        }

//        var colors: [UIColor] = []

        let dataSet = PieChartDataSet(entries: entries, label: "Data")
        var colors: [UIColor] = []
        
        var notHitColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        colors.append(notHitColor)
        colors.append(.popoPink)
        dataSet.colors = colors
        
        dataSet.valueTextColor = .black // データのラベル色
        dataSet.valueFont = UIFont.boldSystemFont(ofSize: 12)
        
        dataSet.drawValuesEnabled = false  // グラフ上のデータ値を非表示
        let chartData = PieChartData(dataSet: dataSet)
        pieChartsView.data = chartData


        API.requestHttp(POPOAPI.base.baseGet, parameters: nil,success: { [self] (response: ApiBaseParam) in
            var baseParam = response
            userDefaults.set(0, forKey: "roulette")
            if baseParam.roulette != nil {
                userDefaults.set(baseParam.roulette, forKey: "roulette")
            }
        },
        failure: { [self] error in
            let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            self.present(alert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            })
            return;
        })
    }
    
    @objc func onTapBackButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.topItem!.title = ""
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(onTapBackButton(_:)))
        
        
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }
    
    // 画面に表示された直後に呼ばれます。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hitPoint == 5 {
            self.navigationItem.title = "ゴールドチャンス"
        }
        if hitPoint == 10 {
            self.navigationItem.title = "シルバーチャンス"
        }
        if hitPoint == 15 {
            self.navigationItem.title = "ブロンズチャンス"
        }
    }

    // スタートボタンを押した際のIBAction
    @IBAction func tapStartButton(_ sender: UIButton) {
        navigationItem.leftBarButtonItem?.isEnabled = false
        print("ポイントポイントポイントポイントポイント", self.point)
        
        if self.point < usePoint {
            let alertController:UIAlertController =
                UIAlertController(title:"ポイントが不足しています",message: "いいねするにはポイント" + String(usePoint) + "p必要です", preferredStyle: .alert)
            let backView = alertController.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // Default のaction
            let defaultAction:UIAlertAction =
                UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                    let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                })

            // Cancel のaction
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                    // 処理
                    print("キャンセル")
                })
            cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
            defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
            // actionを追加
            alertController.addAction(cancelAction)
            alertController.addAction(defaultAction)
            // UIAlertControllerの起動
            self.present(alertController, animated: true, completion: nil)
            return
        }
        self.point = self.point - usePoint
        self.userDefaults.set(Int(self.point), forKey: "point")


        if let roulette = userDefaults.object(forKey: "roulette") as! Int? {
            if roulette == 0 {
                let alert = UIAlertController(title: nil, message: "こちらは現在開催されていません。", preferredStyle: .alert)
                 let backView = alert.view.subviews.last?.subviews.last
                 backView?.layer.cornerRadius = 15.0
                 backView?.backgroundColor = .white
                 self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        alert.dismiss(animated: true, completion: nil)
                        let layere_number = self.navigationController!.viewControllers.count
                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[layere_number-3], animated: true)
                    })
                })
            } else {
                // 初期スピード
                let degree: CGFloat = CGFloat.random(in: 13.0..<18.0)
                if buttonStartFlg {
                    // ストップボタンを押すまでは、定期的に(repeats: true)呼び出される
                    // 回転処理に使われるメソッドは rotateImage)
                    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(rotateImage), userInfo: degree, repeats: true)
                    
                    buttonStartFlg = false
                    // ボタンのタイトルを変更
                    startButton.setTitle("STOP", for: .normal)
                } else {
                    // 定期的な呼び出しを中止する
                    timer.invalidate()
                    // 回転を徐々に止めるためのメソッドを1回だけ(repeats: false)呼び出し
                    // 止めるために使われるメソッドは stopImage
                    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(stopImage), userInfo: degree, repeats: false)
                }
            }
        }
    }
    
    @objc func rotateImage(_ sender: Timer) {
        let degree = sender.userInfo as! CGFloat
        let angle = currentDegree * CGFloat.pi / 180  // Radian
        let affine = CGAffineTransform(rotationAngle: angle)
        pieChartsView.transform = affine
        currentDegree += degree
        currentDegree.formRemainder(dividingBy: 360.0)
    }
    
    // ストップボタンを押した後、止まるまで呼び出される回転処理
    @objc func stopImage(_ sender: Timer) {

        //ポイントを減らすAPI
        apiRequestUsedPoint()

        startButton.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        
        // 呼び出し時に送られれてきた値を CGFloat に変換
        var degree = sender.userInfo as! CGFloat
        let angle = currentDegree * CGFloat.pi / 180  // Radian
        let affine = CGAffineTransform(rotationAngle: angle)
        pieChartsView.transform = affine
        currentDegree += degree
        currentDegree.formRemainder(dividingBy: 360.0)
        // 回転角を減らす
//        degree -= 0.05
        degree -= 1.05
        if degree > 0 {
            // 回転角が正の間は、減らした回転角を使って再度タイマ割り込みを使う
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(stopImage), userInfo: degree, repeats: false)
        } else {

            let layer = pieChartsView.layer
            // 角度を取得する
            let transform: CATransform3D = layer.presentation()!.transform
            let angle: CGFloat = atan2(transform.m12, transform.m11)
            var clear_point = 1 - (hitPoint*0.01)
            var clear = 360 * clear_point
            print("GGGGGGGGGGGGGGG", clear_point, clear)
            print("KOKOKOKOKOKOKOK", radiansToDegress(radians: angle))
            print("SSSSSSSSSSSSSSS", (360 - radiansToDegress(radians: angle)), ">=", clear+0.5)

            if radiansToDegress(radians: angle) >= -0.5 && (360 - radiansToDegress(radians: angle)) >= clear+0.5{
                startButton.isEnabled = true//有効
                navigationItem.leftBarButtonItem?.isEnabled = true
                
                hitAlert()
            } else {
                startButton.isEnabled = false
                navigationItem.leftBarButtonItem?.isEnabled = false
                let alert = UIAlertController(title: "残念", message: "またの挑戦をお願いします", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                    dismiss(animated: true, completion: nil)
                    loadInterstitial()
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
            // 状態を元に戻し、ボタンのタイトルを変更する
            buttonStartFlg = true
            startButton.setTitle("START", for: .normal)
        }
    }
    
    
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3233612928012980/2786126078", request: GADRequest()) { [weak self] (ad, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self?.interstitial = ad
            print("高恋く")
            print(self?.interstitial)
            self?.interstitial?.present(fromRootViewController: self!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: { [self] in
                self?.startButton.isEnabled = true
                self?.navigationItem.leftBarButtonItem?.isEnabled = true
            })
        }
    }
    
    func hitAlert() {
        //アラートコントローラー
        let alert = UIAlertController(title: "おめでとうございます！", message: "amazonギフト券をお送りしますので\n送信先のメールアドレスを入力して下さい", preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = .white

        //OKボタンを生成
         let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
             //複数のtextFieldのテキストを格納
             guard let textFields:[UITextField] = alert.textFields else {return}
             var email:String = ""
             //textからテキストを取り出していく
             for textField in textFields {
                 switch textField.tag {
                     case 1:
                     email = textField.text!
                     default: break
                 }
             }
             self.apiRequestRouletteHit(email)
             print("メールアドレスメールアドレスメールアドレス", email)
        }

        okAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "辞退する", style: .cancel) { (UIAlertAction) -> Void in
            print("閉じる")
        }
        cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        alert.addTextField { (text:UITextField!) in
            text.textColor = .popoTextColor
             text.textAlignment = NSTextAlignment.center
             text.font = UIFont.boldSystemFont(ofSize: 14)
             text.placeholder = "メールアドレス"
             text.text = ""
             if let targetWeight = self.userDefaults.object(forKey: "targetWeight") {
                 text.text = targetWeight as! String
             }
             text.tag = 1
         }
        //アラートを表示
         present(alert, animated: true, completion: nil)
    }

    func apiRequestUsedPoint() {
        let parameters = [
            "used_point": usePoint,
            "status" : 10
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.usedPoint, parameters: parameters,success: { [self] (response: ApiStatus) in
        
        },
        failure: { [self] error in
            print(error)
        })
    }
    
    func apiRequestRouletteHit(_ email: String) {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "email": email,
            "accece_token": "DDDD",
            "type" : hitPoint
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.createRouletteHit, parameters: parameters,success: { [self] (response: ApiStatus) in
            let alertController:UIAlertController =
                UIAlertController(title:"受付完了しました",message: "送信致しましますのでしばらくお待ち下さい",preferredStyle: .alert)
                // Default のaction
                let backView = alertController.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
                let cancelAction:UIAlertAction =
                    UIAlertAction(title: "閉じる",style: .cancel,handler:{
                        (action:UIAlertAction!) -> Void in
                        // 処理
                        dismiss(animated: true)
                    })
                cancelAction.setValue(UIColor.popoGreen, forKey: "titleTextColor")
                // actionを追加
                alertController.addAction(cancelAction)
                // UIAlertControllerの起動
                present(alertController, animated: true, completion: nil)
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
    
    
    
    
//    func mailer() {
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            mail.mailComposeDelegate = self
//            mail.setToRecipients(["popokatsu11@gmail.com"]) // 宛先アドレス
//            mail.setSubject("当選おめでとうございます！！！") // 件名
//            mail.setMessageBody("amazonギフト券をお送り致しますので、送信先のメールアドレスを入力して送信してください\n\n\n【送信先メールアドレス】\n\n\n\n送信せずにメーラーを閉じられますと、amazonギフト券をお送りすることが出ませんのでご注意下さい\n\n\n\nアクセストークン:\(Date())", isHTML: false) // 本文
//            mail.navigationBar.tintColor = .white // ここ追加
//            mail.navigationBar.barTintColor = .red
//            mail.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white] // ここ追加
//            mail.navigationBar.largeTitleTextAttributes = [.foregroundColor : UIColor.white] // ここ追加
//            present(mail, animated: true, completion: nil)
//        } else {
//            print("メール設定されていません")
//            let url: URL = URL(string:"mailto:foo@example.com")!
//            if (UIApplication.shared.canOpenURL(url)) {
//                UIApplication.shared.open(url)
//            } else {
//                print("CANNOT Open URL", url)
//            }
//        }
//    }
//
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        switch result {
//        case .cancelled:
//            print("Email Send Cancelled")
//            controller.dismiss(animated: true, completion: nil)
//        case .saved:
//            print("Email Saved as a Draft")
//            break
//        case .sent:
//            print("Email Sent Successfully")
//            controller.dismiss(animated: true, completion: nil)
//            alert()
//        case .failed:
//            print("Email Send Failed")
//            break
//        default:
//            break
//        }
//    }
//
//    func alert() {
//        let alert: UIAlertController = UIAlertController(title: "送信完了", message: "", preferredStyle:  UIAlertController.Style.alert)
//        // キャンセルボタンの処理
//        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
//            (action: UIAlertAction!) -> Void in
//        })
//        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
//        alert.addAction(cancelAction)
//        //実際にAlertを表示する
//        present(alert, animated: true, completion: nil)
//    }


}

extension RouletteViewController: CAAnimationDelegate {
    func radiansToDegress(radians: CGFloat) -> CGFloat {
        return radians * 180 / CGFloat(Double.pi)
    }
}
