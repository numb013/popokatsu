//
//  Group1ViewController.swift
//  matchness
//
//  Created by user on 2019/06/02.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import PagingMenuController
import SideMenu

class GroupViewController: BaseViewController, UIViewControllerTransitioningDelegate{
    @IBOutlet weak var searchButton: UIBarButtonItem!
    let userDefaults = UserDefaults.standard
    private var myImageView: UIImageView!
    let view_1 = UIView()
    let menuButton = SSBadgeButton()
    var sideMenu: SideMenuNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
        
    func load() {
        // PagingMenuController追加
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options: options)
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        // 高さ調整。この2行を追加
        pagingMenuController.view.frame.origin.y += navBarHeight! + statusBarHeight
        pagingMenuController.view.frame.size.height -= navBarHeight! + statusBarHeight
        
        self.addChild(pagingMenuController)
        self.view.addSubview(pagingMenuController.view)
        pagingMenuController.didMove(toParent: self)
        tabBarController?.tabBar.isHidden = false
        // Do any additional setup after loading the view.
        self.navigationItem.title = "グループ"
        
        // ボタンのインスタンス生成
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        // 任意の場所に設置する
        if UIScreen.main.nativeBounds.height >= 1792 {
            button.layer.position = CGPoint(x: self.view.frame.width - 45, y:self.view.frame.height - 140)
        } else {
            button.layer.position = CGPoint(x: self.view.frame.width - 45, y:self.view.frame.height - 114)
        }
        button.setImage(UIImage(named: "pulus_group"), for: .normal)
        button.backgroundColor = .popoPink
        button.addTarget(self, action: #selector(self.goAddGroup(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 30.0
        // 影の濃さを決める
        button.layer.shadowOpacity = 0.5
        // 影のサイズを決める
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.addSubview(button)
    }

    @objc func goAddGroup(_ sender : Any) {
        let vc = UIStoryboard(name: "GroupEvent", bundle: nil).instantiateViewController(withIdentifier: "GroupEventAdd")
        vc.modalPresentationStyle = .popover
        vc.transitioningDelegate = self
        self.present(vc,animated: true, completion: nil)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "グループ"
        load()
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
        print("メニューーーーーーーーー", userDefaults.string(forKey: "sidemenu"))
        if userDefaults.object(forKey: "sidemenu") != nil {
            menuButton.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 2, bottom: 0, right: 0)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




private struct PagingMenuOptions: PagingMenuControllerCustomizable {

    let pv1 = UIStoryboard(name: "GroupEvent", bundle: nil).instantiateViewController(withIdentifier: "WaitGroup") as! WaitGroupViewController
    let pv2 = UIStoryboard(name: "GroupEvent", bundle: nil).instantiateViewController(withIdentifier: "JoinGroup") as! JoinGroupViewController
    let pv3 = UIStoryboard(name: "GroupEvent", bundle: nil).instantiateViewController(withIdentifier: "EndGroup") as! EndGroupViewController
    let userDefaults = UserDefaults.standard

    fileprivate var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    fileprivate var pagingControllers: [UIViewController] {
        return [pv1, pv2, pv3]
//        if userDefaults.object(forKey: "join_group") as? Int == 1 {
//            return [pv2, pv1, pv3]
//        } else {
//            return [pv1, pv2, pv3]
//        }
    }

    fileprivate struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .infinite(widthMode: .flexible, scrollingMode: .scrollEnabled)
        }
        var height: CGFloat {
            return 45
        }
        var backgroundColor: UIColor {
            return UIColor.black
        }
        
        var selectedBackgroundColor: UIColor {
            return UIColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 1.0)
        }
        var focusMode: MenuFocusMode {
            return .roundRect(radius: 1, horizontalPadding: 1, verticalPadding: 1, selectedColor: UIColor(red: 0.1, green: 0.7, blue: 0.7, alpha: 0.7))
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItem1(), MenuItem2(), MenuItem3()]
//            let userDefaults = UserDefaults.standard
//            if userDefaults.object(forKey: "join_group") as? Int == 1 {
//                return [MenuItem2(), MenuItem1(), MenuItem3()]
//            } else {
//                return [MenuItem1(), MenuItem2(), MenuItem3()]
//            }
        }
    }

    fileprivate struct MenuItem1: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "募集中       ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            var text = "参加中        "
            return .text(title: MenuItemText(text: text, color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
    fileprivate struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "参加済       ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }

}
