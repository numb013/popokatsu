//
//  NoticeViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/05/04.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit
import PagingMenuController

@available(iOS 13.0, *)
class NoticeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // PagingMenuController追加
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options: options)
//        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

        // 高さ調整。この2行を追加
        pagingMenuController.view.frame.origin.y += statusBarHeight + 8
        pagingMenuController.view.frame.size.height -= statusBarHeight + 8
        
        
        print("高さ高さ高さ高さ高さ高さ高さ")
        print(pagingMenuController.view.frame.origin.y)
        print(pagingMenuController.view.frame.size.height)
        
        self.addChild(pagingMenuController)
        self.view.addSubview(pagingMenuController.view)
        pagingMenuController.didMove(toParent: self)

        tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
//        navigationController!.navigationBar.topItem!.title = ""
//        self.navigationItem.title = "お知らせ"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationItem.title = "お知らせ"
//        navigationController!.navigationBar.topItem!.title = ""
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

@available(iOS 13.0, *)
private struct PagingMenuOptions: PagingMenuControllerCustomizable {

    let pv1 = UIStoryboard(name: "Notice", bundle: nil).instantiateViewController(withIdentifier: "All") as! AllNoticeViewController

    let pv2 = UIStoryboard(name: "Notice", bundle: nil).instantiateViewController(withIdentifier: "Group") as! GroupNoticeViewController

    let pv3 = UIStoryboard(name: "Notice", bundle: nil).instantiateViewController(withIdentifier: "Popo") as! PopoNoticeViewController

    let pv4 = UIStoryboard(name: "Notice", bundle: nil).instantiateViewController(withIdentifier: "Tweet") as! TweetNoticeViewController

    
    fileprivate var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    fileprivate var pagingControllers: [UIViewController] {
        return [pv1, pv2, pv3, pv4]
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
            return [MenuItem1(), MenuItem2(), MenuItem3(), MenuItem4()]
        }
    }

    fileprivate struct MenuItem1: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "全て           ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "グループ        ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
    fileprivate struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "運営           ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }

    fileprivate struct MenuItem4: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "つぶやき           ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
}
