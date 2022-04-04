//
//  TermCompViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/05/11.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import SwiftyJSON

class TermCompViewController: UIViewController, UITextViewDelegate{
    private var requestAlamofire: Alamofire.Request?
    let userDefaults = UserDefaults.standard
    var device = 1
    public var errorData: Dictionary<String, ApiErrorAlert> = [String: ApiErrorAlert]();

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var comp: UIButton!

    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load()
    }

    func load() {
        let baseString = "お客様に安心してお使い頂けるよう、\n利用規約に同意して頂くようお願いいたします。\n\n私は以下の\n「利用規約」及び「プライバシーポリシー」に同意します。"
        let attributedString = NSMutableAttributedString(string: baseString)
        attributedString.addAttribute(.link,value:"TermOfUseLink",range: NSString(string: baseString).range(of: "「利用規約」"))
        attributedString.addAttribute(.link,value:"PrivacyPolicyLink",range: NSString(string: baseString).range(of: "「プライバシーポリシー」"))
        textView.attributedText = attributedString
        textView.isSelectable = true
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 15)
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)
        comp.isEnabled = false
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        self.userDefaults.set("1", forKey: "login_step_0")
        loadView()
        viewDidLoad()
    }

    @IBAction func pushCheckButton(_ sender: Any) {
        self.checkButton.isSelected = !self.checkButton.isSelected
        if (self.checkButton.isSelected == true) {
            self.comp.backgroundColor =  #colorLiteral(red: 0.9762895703, green: 0, blue: 0.5041214228, alpha: 1)
            self.comp.isEnabled = true
        } else {
            self.comp.isEnabled = false
            self.comp.backgroundColor =  #colorLiteral(red: 0.4803626537, green: 0.05874101073, blue: 0.1950398982, alpha: 1)
        }
    }
    
    @IBAction func PushComp(_ sender: Any) {
        self.userDefaults.set("1", forKey: "login_step_0")
        self.performSegue(withIdentifier: "toStartTop", sender: nil)
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlString = URL.absoluteString
        if urlString == "TermOfUseLink" {
            let webPage = ApiConfig.SITE_BASE_URL + "/terms"
            let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
            present(safariVC, animated: true, completion: nil)
        }
        if urlString == "PrivacyPolicyLink" {
            let webPage = ApiConfig.SITE_BASE_URL + "/privacy"
            let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
            present(safariVC, animated: true, completion: nil)
        }
        return false
    }
}
