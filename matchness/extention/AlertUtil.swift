import Foundation
import UIKit

class Alert: UIAlertController {
    class func error(alertNum : Dictionary<String, ApiErrorAlert>, viewController: UIViewController) {
        let alertController:UIAlertController =
            UIAlertController(title:"ポイントが不足しています",message: "ポイント変換が必要です", preferredStyle: .alert)
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Default のaction
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
                (action:UIAlertAction!) -> Void in
                // 処理
                let storyboard: UIStoryboard = viewController.storyboard!
                //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
                let multiple = storyboard.instantiateViewController(withIdentifier: "pointChange")
                multiple.modalPresentationStyle = .fullScreen
                //ここが実際に移動するコードとなります
                viewController.present(multiple, animated: false, completion: nil)

            })
        
        // Cancel のaction
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                (action:UIAlertAction!) -> Void in
                // 処理
                print("キャンセル")
            })
        cancelAction.setValue(#colorLiteral(red: 0, green: 0.71307832, blue: 0.7217405438, alpha: 1), forKey: "titleTextColor")
        defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
        // actionを追加
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        // UIAlertControllerの起動
        viewController.present(alertController, animated: true, completion: nil)
    }

    class func common(alertNum : Dictionary<String, ApiErrorAlert>, viewController: UIViewController) {
        let alert = UIAlertController(title: alertNum["0"]?.title, message: alertNum["0"]?.message, preferredStyle: .alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if alertNum["0"]?.code != "100" {
            viewController.present(alert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            })
        } else {
            // アプリ更新画面に飛ばす処理　code=100
            let defaultAction:UIAlertAction =
                UIAlertAction(title: alertNum["0"]?.label,style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                    DispatchQueue.main.async {
                        guard let url: URL = URL(string: "https://itunes.apple.com/jp/app/apple-store/id1514735600") else { return }
                        // URLを開けるかをチェックする
                        if !UIApplication.shared.canOpenURL(url) {
                            return
                        }
                        // URLを開く
                        UIApplication.shared.open(url, options: [:]) { success in
                            if success {
                                print("successful")
                            }
                        }
                    }
                })
            defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
            // actionを追加
            alert.addAction(defaultAction)
            // UIAlertControllerの起動
            viewController.present(alert, animated: true, completion: nil)
        }

    }

    class func group(alertNum : Dictionary<String, ApiErrorAlert>, viewController: UIViewController) {
        let alertController:UIAlertController =
            UIAlertController(title:alertNum["0"]?.title,message: alertNum["0"]?.message, preferredStyle: .alert)
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Default のaction
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "ランクアップ",style: .destructive,handler:{
                (action:UIAlertAction!) -> Void in
                let storyboard = UIStoryboard(name: "RankUp", bundle: nil)
                //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
                let multiple = storyboard.instantiateViewController(withIdentifier: "rankup") as! RankUpViewController
                multiple.modalPresentationStyle = .fullScreen
                multiple.now_rank = alertNum["0"]?.rank! as! Int
                //ここが実際に移動するコードとなります
                viewController.present(multiple, animated: false, completion: nil)
            })
        
        // Cancel のaction
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "閉じる",style: .cancel,handler:{
                (action:UIAlertAction!) -> Void in
                // 処理
                print("キャンセル")
            })
        cancelAction.setValue(#colorLiteral(red: 0, green: 0.71307832, blue: 0.7217405438, alpha: 1), forKey: "titleTextColor")
        defaultAction.setValue(#colorLiteral(red: 0.9884889722, green: 0.3815950453, blue: 0.7363485098, alpha: 1), forKey: "titleTextColor")
        // actionを追加
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        // UIAlertControllerの起動
        viewController.present(alertController, animated: true, completion: nil)
        
    }
    
    
    class func helthError(alertNum : Dictionary<String, ApiErrorAlert>, viewController: UIViewController) {

        let alertController:UIAlertController =
            UIAlertController(title:"データが取得できません",message: "設定アプリを起動し、「プライバシー」→「ヘルスケア」→「POPOKATSU」と選択し、全ての項目をオンにして下さい", preferredStyle: .alert)
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 15.0
        backView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Cancel のaction
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "閉じる",style: .cancel,handler:{
                (action:UIAlertAction!) -> Void in
                // 処理
                print("キャンセル")
            })
        cancelAction.setValue(#colorLiteral(red: 0, green: 0.71307832, blue: 0.7217405438, alpha: 1), forKey: "titleTextColor")
        // actionを追加
        alertController.addAction(cancelAction)
        // UIAlertControllerの起動
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func openAppStore(_ appId: String) {
        DispatchQueue.main.async {
            guard let url: URL = URL(string: "https://itunes.apple.com/jp/app/apple-store/id" + appId) else { return }
            // URLを開けるかをチェックする
            if !UIApplication.shared.canOpenURL(url) {
                return
            }
            // URLを開く
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("successful")
                }
            }
        }
    }
    
}

