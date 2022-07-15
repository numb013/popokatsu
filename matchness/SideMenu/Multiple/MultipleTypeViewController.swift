//
//  MultipleTypeViewController.swift
//  matchness
//
//  Created by user on 2019/06/04.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MultipleTypeViewController: ButtonBarPagerTabStripViewController {
    
    var status:Int = 0
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor.black
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor.black
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = .popoPink
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //タブバー表示
        if status == 0 {
            navigationController!.navigationBar.topItem!.title = "足あと"
        } else if status == 3 {
            navigationController!.navigationBar.topItem!.title = "いいね"
        } else if status == 6 {
            navigationController!.navigationBar.topItem!.title = "マイリスト"
        }
    }
    
    

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        let firstVC = UIStoryboard(name: "Multiple", bundle: nil).instantiateViewController(withIdentifier: "MultipleFirst") as! MultipleFirstViewController
        let secondVC = UIStoryboard(name: "Multiple", bundle: nil).instantiateViewController(withIdentifier: "MultipleSecond") as! MultipleSecondViewController
        firstVC.status = self.status;
        secondVC.status = self.status;

        let childViewControllers:[UIViewController] = [firstVC, secondVC]
        return childViewControllers
    }
}
