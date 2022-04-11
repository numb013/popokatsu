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
    
    var buttonStartFlg = true
    // 現時点での回転角
    var currentDegree: CGFloat = 0
    // 定期割り込みのための Timer のインスタンス
    var timer = Timer()
    var interval: TimeInterval = 0.01
    
    var hitPoint:Double = 5
    
    
    @IBOutlet weak var yajirushi: UIImageView!
    // ボタン
    @IBOutlet weak var startButton: UIButton!
    // ルーレット画像
    @IBOutlet weak var pieChartsView: PieChartView!

    override func viewDidLoad() {
        pieChartsView.usePercentValuesEnabled = true
        pieChartsView.legend.enabled = false
        pieChartsView.highlightPerTapEnabled = false
        pieChartsView.isUserInteractionEnabled = false
        
        let values: [String] = ["AAAA", "BBBB"]
        let date : [Double] = [1,2]
        var entries: [ChartDataEntry] = [
            PieChartDataEntry(value: 100-hitPoint, label: "ハズレ"),
            PieChartDataEntry(value: hitPoint, label: "当たり")
        ]
        
//        for (i, value) in values.enumerated(){
//            entries.append(PieChartDataEntry(value: date[i], label: values[i]))
//        }

        var colors: [UIColor] = []

        let dataSet = PieChartDataSet(entries: entries, label: "Data")
        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }

        dataSet.colors = colors
        dataSet.valueTextColor = .black // データのラベル色
        dataSet.drawValuesEnabled = false  // グラフ上のデータ値を非表示
        let chartData = PieChartData(dataSet: dataSet)
        pieChartsView.data = chartData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "ルーレット"
        navigationController!.navigationBar.topItem!.title = ""
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }

    // スタートボタンを押した際のIBAction
    @IBAction func tapStartButton(_ sender: UIButton) {
        // 初期スピード
        let degree: CGFloat = CGFloat.random(in: 13.0..<18.0)


//       let randomInt = CGFloat.random(in: 13.0..<18.0)
        
        if buttonStartFlg {
            // ストップボタンを押すまでは、定期的に(repeats: true)呼び出される
            // 回転処理に使われるメソッドは rotateImage)
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(rotateImage), userInfo: degree, repeats: true)
            buttonStartFlg = false
            // ボタンのタイトルを変更
            startButton.setTitle("Stop", for: .normal)
        } else {
            // 定期的な呼び出しを中止する
            timer.invalidate()
            // 回転を徐々に止めるためのメソッドを1回だけ(repeats: false)呼び出し
            // 止めるために使われるメソッドは stopImage
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(stopImage), userInfo: degree, repeats: false)
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
        startButton.isEnabled = false
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

            startButton.isEnabled = true
            
            if radiansToDegress(radians: angle) >= -0.5 && (360 - radiansToDegress(radians: angle)) >= clear+0.5{
                startButton.isEnabled = true
                let alert = UIAlertController(title: "当たり", message: "OKを押すとメーラーが立ち上がりますので送信ボタンを押してください", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                    dismiss(animated: true, completion: nil)

                    mailer()
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "ハズレ", message: "OKを押すとメーラーが立ち上がりますので送信ボタンを押してください", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//                        startButton.isEnabled = true
//                    })
//                    dismiss(animated: true, completion: nil)
//                    loadInterstitial()
                    
                    mailer()
                    
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
            // 状態を元に戻し、ボタンのタイトルを変更する
            buttonStartFlg = true
            startButton.setTitle("Start", for: .normal)
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
        }
    }

    func mailer() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["popokatsu11@gmail.com"]) // 宛先アドレス
            mail.setSubject("当選おめでとうございます！！！") // 件名
            mail.setMessageBody("amazonギフト券をお送り致しますので、送信先のメールアドレスを入力して送信してください\n\n\n【送信先メールアドレス】\n\n\n\n送信せずにメーラーを閉じられますと、amazonギフト券をお送りすることが出ませんのでご注意下さい\n\n\n\nアクセストークン:\(Date())", isHTML: false) // 本文
            mail.navigationBar.tintColor = .white // ここ追加
            mail.navigationBar.barTintColor = .red
            mail.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white] // ここ追加
            mail.navigationBar.largeTitleTextAttributes = [.foregroundColor : UIColor.white] // ここ追加
            present(mail, animated: true, completion: nil)
        } else {
            print("メール設定されていません")
            let url: URL = URL(string:"mailto:foo@example.com")!
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url)
            } else {
                print("CANNOT Open URL", url)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Email Send Cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .saved:
            print("Email Saved as a Draft")
            break
        case .sent:
            print("Email Sent Successfully")
            controller.dismiss(animated: true, completion: nil)
            alert()
        case .failed:
            print("Email Send Failed")
            break
        default:
            break
        }
    }
    
    func alert() {
        let alert: UIAlertController = UIAlertController(title: "送信完了", message: "", preferredStyle:  UIAlertController.Style.alert)
        // キャンセルボタンの処理
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        //実際にAlertを表示する
        present(alert, animated: true, completion: nil)
    }




}

extension RouletteViewController: CAAnimationDelegate {
    func radiansToDegress(radians: CGFloat) -> CGFloat {
        return radians * 180 / CGFloat(Double.pi)
    }
}
