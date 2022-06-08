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
        tableView.separatorStyle = .none

        tableView.contentInset.bottom = 80

        self.tableView.register(UINib(nibName: "RouletteViewCell", bundle: nil), forCellReuseIdentifier: "RouletteViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = "ルーレット"
        navigationController!.navigationBar.topItem!.title = ""
        //タブバー表示
        tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouletteViewCell") as! RouletteViewCell
        if indexPath.row == 0 {
            cell.title.text = "ゴールドチャンス"
            cell.title.textColor = .popoGold
            cell.backgroundColor = #colorLiteral(red: 0.8230579495, green: 0.6966378093, blue: 0.2210325897, alpha: 0.2)
            cell.headView.backgroundColor = .popoGold
            cell.headView1.backgroundColor = .popoGold
        } else if indexPath.row == 1 {
            cell.title.text = "シルバーチャンス"
            cell.title.textColor = .popoSilver
            cell.backgroundColor = #colorLiteral(red: 0.6795967221, green: 0.6755590439, blue: 0.6827017665, alpha: 0.2)
            cell.headView.backgroundColor = .popoSilver
            cell.headView1.backgroundColor = .popoSilver
        } else if indexPath.row == 2 {
            cell.title.text = "ブロンズチャンス"
            cell.title.textColor = .popoBronze
            cell.backgroundColor = #colorLiteral(red: 0.6633054614, green: 0.4208735824, blue: 0.3299359679, alpha: 0.2)
            cell.headView.backgroundColor = .popoBronze
            cell.headView1.backgroundColor = .popoBronze
        }

        
        if indexPath.row == 3 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "rouletteCell")
            cell.textLabel!.numberOfLines = 0
            cell.backgroundColor =  UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            var text = "ルーレットチャンスとは\n\nルーレットで当たりが出るとアマゾンギフト券をプレゼント致します！\n歩いて貯めたポイントを使って是非チャレンジしてみて下さい\nなお期間限定で不定期開催いたしますので急に終了する場合もございますのでご了承ください\n\n・一回ルーレットにチャレンジする為には100pt必要になります\n\n・ゴールドチャンス\n当たりが出ればアマゾンギフト500円分プレゼント致します\n・シルバーチャンス\n当たりが出ればアマゾンギフト300円分プレゼント致します\n・ブロンズチャンス\n当たりが出ればアマゾンギフト100円分プレゼント致します\n\n・アマゾンギフト券のプレゼント方法\nプレゼント方法はメールでお送りする方法のみになりますので、当たりが出た際はメールアドレスの入力画面が出てきますので入力を必ず行って下さい\n\n・当たりが出てプレゼントが送信されるまで\n一週間以内には送信致します"

            cell.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
            cell.textLabel!.textColor = .popoTextColor
            cell.textLabel!.text = text
            return cell
        }
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let vc = UIStoryboard(name: "Roulette", bundle: nil).instantiateViewController(withIdentifier: "Roulette") as! RouletteViewController

        if indexPath.row == 0 {
            vc.hitPoint = 5
        }
        if indexPath.row == 1 {
            vc.hitPoint = 10
        }
        if indexPath.row == 2 {
            vc.hitPoint = 15
        }
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            tableView.estimatedRowHeight
            return UITableView.automaticDimension
        }

        return 110
    }
    
}

