//
//  ChatViewController.swift
//  matchness
//
//  Created by user on 2019/06/04.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SideMenu

class ChatViewController: ButtonBarPagerTabStripViewController {

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
        settings.style.selectedBarBackgroundColor = .popoPink

        super.viewDidLoad()

        if let tabBarItem = self.tabBarController?.tabBar.items?[3] as? UITabBarItem {
            tabBarItem.badgeValue = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "メッセージ"
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
        print("ナビナビナビきてる？？？チャット", userDefaults.object(forKey: "sidemenu"))
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
        let firstVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "First")
        let secondVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "Second")
        let childViewControllers:[UIViewController] = [firstVC, secondVC]
        return childViewControllers
    }
}
