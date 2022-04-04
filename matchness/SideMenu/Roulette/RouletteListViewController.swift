//
//  RouletteListViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2022/03/11.
//  Copyright © 2022 a2c. All rights reserved.
//

import UIKit

class RouletteListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var list = [
        ["title": "ルーレット", "icon": "calendar"],
        ["title": "カレンダー", "icon": "calendar"],
        ["title": "歩数計", "icon": "stepdata"],
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as! SideMenuCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let vc = UIStoryboard(name: "Roulette", bundle: nil).instantiateViewController(withIdentifier: "Roulette") as! RouletteViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

