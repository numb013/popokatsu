//
//  WeekRankingSetViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/07/03.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SideMenu

@available(iOS 13.0, *)
class WeekRankingSetViewController: ButtonBarPagerTabStripViewController, UIViewControllerTransitioningDelegate {
    
    var editBarButtonItem: UIBarButtonItem!
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
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)

        super.viewDidLoad()

        self.navigationItem.title = "週間ランキング"
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
        
        editBarButtonItem = UIBarButtonItem(title: "本日", style: .done, target: self, action: #selector(editBarButtonTapped(_:)))
        self.navigationItem.rightBarButtonItems = [editBarButtonItem]
    }
    
    // "編集"ボタンが押された時の処理
    @objc func editBarButtonTapped(_ sender: UIBarButtonItem) {
        let vc = UIStoryboard(name: "Chart", bundle: nil).instantiateInitialViewController()! as! MyDateStepViewController
//            navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .popover
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "週間ランキング"
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

        menuButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        menuButton.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        print("メニューーーーーーーーー", userDefaults.string(forKey: "sidemenu"))
        if userDefaults.object(forKey: "sidemenu") != nil {
            menuButton.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)
            menuButton.badge = userDefaults.string(forKey: "sidemenu")
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
        let firstVC = UIStoryboard(name: "WeekRanking", bundle: nil).instantiateViewController(withIdentifier: "first_week")
        let secondVC = UIStoryboard(name: "WeekRanking", bundle: nil).instantiateViewController(withIdentifier: "second_week")
        let childViewControllers:[UIViewController] = [firstVC, secondVC]
        return childViewControllers
    }
}
