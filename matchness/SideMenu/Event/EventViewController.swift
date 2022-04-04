//
//  EventViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2020/05/04.
//  Copyright © 2020 a2c. All rights reserved.
//

import UIKit
import PagingMenuController

class EventViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "イベント"
        navigationController!.navigationBar.topItem!.title = ""
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private struct PagingMenuOptions: PagingMenuControllerCustomizable {

    let pv1 = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(withIdentifier: "wishEvent") as! WishViewController
    let pv2 = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(withIdentifier: "RankUp") as! RankUpViewController
    let pv3 = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(withIdentifier: "wishEvent") as! WishViewController
    let pv4 = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(withIdentifier: "RankUp") as! RankUpViewController

    
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
            return .text(title: MenuItemText(text: "目標達成  ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "ランクアップ  ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
    
    fileprivate struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "目標達成  ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }

    fileprivate struct MenuItem4: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "ランクアップ  ", color: UIColor.gray, selectedColor: UIColor.white))
        }
    }
}
