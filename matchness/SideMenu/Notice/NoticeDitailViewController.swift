//
//  NoticeDetailViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

class NoticeDetailViewController: UIViewController{

    let userDefaults = UserDefaults.standard
    var body = String()

    @IBOutlet weak var noticeDetail: UITextView!
    var selectRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
//         Do any additional setup after loading the view.
        noticeDetail.text = self.body
//        navigationController!.navigationBar.topItem!.title = ""
            // テキストを編集不可にする.
        noticeDetail.isEditable = false
    }
}