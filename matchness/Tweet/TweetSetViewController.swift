//
//  TweetSetViewController.swift
//  matchness
//
//  Created by user on 2019/06/04.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SideMenu

@available(iOS 13.0, *)
class TweetSetViewController: ButtonBarPagerTabStripViewController {
    var sideMenu: SideMenuNavigationController?
    let menuButton = SSBadgeButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor.black
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor.black
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = .popoTextGreen

        super.viewDidLoad()

        self.navigationItem.title = "つぶやき"
        //タブバー表示
        tabBarController?.tabBar.isHidden = false

        // ボタンのインスタンス生成
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        // 任意の場所に設置する
        if UIScreen.main.nativeBounds.height >= 1792 {
            button.layer.position = CGPoint(x: self.view.frame.width - 45, y:self.view.frame.height - 140)
        } else {
            button.layer.position = CGPoint(x: self.view.frame.width - 45, y:self.view.frame.height - 114)
        }
        button.setImage(UIImage(named: "tweeticon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 12)
        button.backgroundColor = .popoPink
        button.addTarget(self, action: #selector(self.goAddTweet(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 30.0
        // 影の濃さを決める
        button.layer.shadowOpacity = 0.5
        // 影のサイズを決める
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.addSubview(button)
    }

    @objc func goAddTweet(_ sender : Any) {
        let addTweet = AddTweetView()
        navigationController?.pushViewController(addTweet, animated: true)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "つぶやき"
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
        //サイドメニューセット
        sideMenuButtonSet()
    }
    
    func sideMenuButtonSet() {
        menuButton.frame = CGRect(x: 0, y: 0, width: 30, height: 0)
        menuButton.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if userDefaults.object(forKey: "sidemenu") != nil {
            menuButton.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 2, bottom: 0, right: 0)
            menuButton.badge = userDefaults.string(forKey: "sidemenu")
        } else {
            menuButton.badge = nil
        }
        menuButton.addTarget(self,action: #selector(self.sideMenu(_ :)),for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    @objc func sideMenu(_ sender: UIBarButtonItem) {
        print("メニュータップ")
        menuButton.badgeLabelHidden()
        sideMenu = SideMenuNavigationController(rootViewController: SideMenuController())
        sideMenu!.leftSide = false
        //メニューの陰影度
        sideMenu!.presentationStyle.onTopShadowOpacity = 0.9
        //メニューの動き
        sideMenu!.presentationStyle = .viewSlideOutMenuIn
        //メインの透明度
        sideMenu!.presentationStyle.presentingEndAlpha = 0.2

        sideMenu!.menuWidth = 320
        
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)

        present(sideMenu!, animated: true)
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        let firstVC = UIStoryboard(name: "Tweet", bundle: nil).instantiateViewController(withIdentifier: "first_tweet")
        let secondVC = UIStoryboard(name: "Tweet", bundle: nil).instantiateViewController(withIdentifier: "second_tweet")
        let childViewControllers:[UIViewController] = [firstVC, secondVC]
        return childViewControllers
    }
}
