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
        noticeDetail.text = self.body
        // テキストを編集不可にする.
        noticeDetail.isEditable = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "お知らせ詳細"
        navigationController!.navigationBar.topItem!.title = ""
        navigationController!.navigationBar.tintColor = .white
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }

}

