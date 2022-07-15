//
//  SideMenuButton.swift
//  matchness
//
//  Created by 中村篤史 on 2022/06/25.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class SideMenuButton {
    func sideMenuButtonSet(_ self:UIViewController) {
        let menuButton = SSBadgeButton()
        menuButton.frame = CGRect(x: 0, y: 0, width: 30, height: 0)
        menuButton.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if userDefaults.object(forKey: "sidemenu") != nil {
            menuButton.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 2, bottom: 0, right: 0)
            menuButton.badge = userDefaults.string(forKey: "sidemenu")
        }
        menuButton.addTarget(self,action: #selector(self.sideMenu(_ :)),for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    @objc func sideMenu(_ sender: UIBarButtonItem) {
        menuButton.badgeLabelHidden()
        print("メニュータップ")
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
}
