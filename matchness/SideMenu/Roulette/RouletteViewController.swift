//
//  RouletteViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2022/02/08.
//  Copyright © 2022 a2c. All rights reserved.
//

import UIKit
import Charts

class RouletteViewController: UIViewController {
    var buttonStartFlg = true
    // 現時点での回転角
    var currentDegree: CGFloat = 0
    // 定期割り込みのための Timer のインスタンス
    var timer = Timer()
    var interval: TimeInterval = 0.01
    
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
            PieChartDataEntry(value: 95, label: "ハズレ"),
            PieChartDataEntry(value: 5, label: "当たり")
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
        degree -= 0.05
        
        if degree > 0 {
            // 回転角が正の間は、減らした回転角を使って再度タイマ割り込みを使う
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(stopImage), userInfo: degree, repeats: false)
        } else {

            let layer = pieChartsView.layer
            // 角度を取得する
            let transform: CATransform3D = layer.presentation()!.transform
            let angle: CGFloat = atan2(transform.m12, transform.m11)
            var testAngle = radiansToDegress(radians: angle) + 90
            if testAngle < 0 {
                testAngle = 360 + testAngle
            }

            if radiansToDegress(radians: angle) >= 0.0 && radiansToDegress(radians: angle) <= 18.0 {
                startButton.isEnabled = true
                let alert = UIAlertController(title: "当たり", message: String("\(Int(radiansToDegress(radians: angle)))°"), preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            } else {
                startButton.isEnabled = true
                let alert = UIAlertController(title: "ハズレ", message: String("\(Int(radiansToDegress(radians: angle)))°"), preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
            // 状態を元に戻し、ボタンのタイトルを変更する
            buttonStartFlg = true
            startButton.setTitle("Start", for: .normal)
        }
    }
}

extension RouletteViewController: CAAnimationDelegate {
    func radiansToDegress(radians: CGFloat) -> CGFloat {
        return radians * 180 / CGFloat(Double.pi)
    }
}
