//
//  PopoNoticeViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/08/08.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

class VersionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
        
    @IBOutlet weak var tableView: UITableView!
    var status = 0

    
    let setumeiText = ["【グループとは】\n複数のユーザーで定められた期間内に歩いた歩数を共有して競い合えるイベント的機能です\n\nグループ内ではグループチャットがポイント無しで出来るのでグループメンバー同士、コミュニーケーションを取りながら楽んでいただけると思います。\n\n【グループに参加】\nグループ画面から募集中のグループに参加希望を出して、あとは待つだけになります。\nその後グループの開催者が参加希望を選択してグループを開催します。\n\n【グループを作成】\nグループを作成する為には、グループ画面の左上の「作成」ボタンを押して作成画面に移動します。\nグルールプ作成には、まず200ポイントが必要になります\nグループのオプションで追加ポイントが必要になります。\nグループの詳細を入力して作成します\n\n【グループの開催方法】\nグループを作成したら、募集中に表示されます\nユーザーがあなたの作成したグループに参加希望が来たら、グループ承認画面からステータスを選択にして人数が、あなたのグループの参加人数が満たしたらグループを開催できます。\n\n開催する際、「本日」と「翌日」開催の選択が出てきます\n本日から開催を選択すると現在の日にちの0時からのスタートとなります\nもし開催ボタンを押した時刻が23時だった場合で開催期間を2日に選択していた場合、1時間と1日が開催期間になりますのでご注意下さい\n\n【グループの削除】\n作成したグループに募集が無く削除した場合は\n作成に仕様したポイントの返却はれませんのでご注意下さい\n"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        self.tableView.register(UINib(nibName: "PointExplanationTableViewCell", bundle: nil), forCellReuseIdentifier: "PointExplanationTableViewCell")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "まだお知らせはありません", attributes:stringAttributes)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointExplanationTableViewCell") as! PointExplanationTableViewCell
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PointExplanationTableViewCell") as! PointExplanationTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.pointExplanationImage?.image = UIImage(named: "rank_setumei")
            return cell

        } else if indexPath.row == 1 {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "userDetailInfo")
            cell.textLabel!.numberOfLines = 0
            cell.backgroundColor =  UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel!.text = setumeiText[0]
            return cell

        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 450
        } else if indexPath.row == 1 {
            tableView.estimatedRowHeight = 200 //セルの高さ
            return UITableView.automaticDimension //自動設定
        }
        return 100
     }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
