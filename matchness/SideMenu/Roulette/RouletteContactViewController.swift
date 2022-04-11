//
//  ContactViewController.swift
//  dope-f
//
//  Created by 中村 篤史 on 2022/02/01.
//

import UIKit
import MessageUI
import CoreTelephony

class RouletteContactViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "お問い合わせ"
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.topItem!.title = ""
    }

    
    func mailer() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["popokatsu11@gmail.com"]) // 宛先アドレス
            mail.setSubject("当選おめでとうございます！！！") // 件名
            mail.setMessageBody("内容内容内容内容内容内容内容内容内容内容内容", isHTML: false) // 本文
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

