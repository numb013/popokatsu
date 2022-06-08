//
//  SideMenuCollectionCell.swift
//  matchness
//
//  Created by 中村篤史 on 2021/12/11.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

protocol SideMenuProtocol: class {
    func selected(_ vc: UIViewController, _ type:Int)
}

class SideMenuCollectionCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: SideMenuProtocol?
    var width:CGFloat = 0.0
    var type = 1
    
    var menuList1 = [
        ["title": "ルーレットチャンス", "icon": "roulette"],
        ["title": "カレンダー", "icon": "calendar"],
        ["title": "歩数計", "icon": "stepdata"],
        ["title": "健康グラフ", "icon": "graph"],
        ["title": "足あと", "icon": "foot"],
        ["title": "いいね", "icon": "like"],
        ["title":"プロフィール", "icon": "prolile"],
        ["title": "ポイント交換", "icon": "change"],
        ["title": "設定", "icon": "setting"],
        ["title": "お知らせ", "icon": "notice"],
        ["title": "ランクアップ", "icon": "rankup"],
        ["title": "今週の目標", "icon": "mokuhyou"],
        ["title": "マイリスト", "icon": "favorite"],
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SideCell", bundle: nil), forCellWithReuseIdentifier: "SideCell")
        collectionView.register(UINib(nibName: "SideWidthCell", bundle: nil), forCellWithReuseIdentifier: "SideWidthCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuList1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SideWidthCell", for: indexPath as IndexPath) as! SideWidthCell
//            cell.title.text = menuList1[indexPath.row]["title"]
//            cell.iconImage.image = UIImage(named: menuList1[indexPath.row]["icon"]!)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SideCell", for: indexPath as IndexPath) as! SideCell
        cell.title.text = menuList1[indexPath.row]["title"]
        cell.iconImage.image = UIImage(named: menuList1[indexPath.row]["icon"]!)
        cell.badge.isHidden = true

        if indexPath.row == 4 {
            if let count = userDefaults.object(forKey: "footprint") as! Int? {
                print("足跡のnoti", count)
                if count != 0 {
                    cell.badge.isHidden = false
                    cell.badge.text = String(count ?? 0)
                    userDefaults.removeObject(forKey: "sidemenu")
                }
            }
        }

        if indexPath.row == 5 {
            if let count = userDefaults.object(forKey: "like") as! Int? {
                print("いいねのnoti", count)
                if count != 0 {
                    cell.badge.isHidden = false
                    cell.badge.text = String(count ?? 0)
                    userDefaults.removeObject(forKey: "sidemenu")
                }
            }
        }

        if indexPath.row == 9 {
            if let count = userDefaults.object(forKey: "notice") as! Int? {
                print("お知らせのnoti", count)
                if count != 0 {
                    cell.badge.isHidden = false
                    cell.badge.text = String(count ?? 0)
                    userDefaults.removeObject(forKey: "sidemenu")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            let vc = UIStoryboard(name: "Roulette", bundle: nil).instantiateViewController(withIdentifier: "RouletteList") as! RouletteListViewController
            type = 2
            delegate?.selected(vc, type)
        }
        
        if indexPath.row == 1 {
            let vc = UIStoryboard(name: "Calender", bundle: nil).instantiateViewController(withIdentifier: "NewCalendar") as! CalendarViewController
            delegate?.selected(vc, type)
        }
        
        if indexPath.row == 2 {
            let vc = UIStoryboard(name: "Chart", bundle: nil).instantiateInitialViewController()! as! MyDateStepViewController
            delegate?.selected(vc, type)
        }
        
        if indexPath.row == 3 {
            let vc = UIStoryboard(name: "Graph", bundle: nil).instantiateViewController(withIdentifier: "Graph") as! GraphViewController
            delegate?.selected(vc, type)
        }

        if indexPath.row == 4 {
            let vc = UIStoryboard(name: "Multiple", bundle: nil).instantiateViewController(withIdentifier: "MultipleType") as! MultipleTypeViewController
            vc.status = 0
            delegate?.selected(vc, type)
        }
        if indexPath.row == 5 {
            let vc = UIStoryboard(name: "Multiple", bundle: nil).instantiateViewController(withIdentifier: "MultipleType") as! MultipleTypeViewController
            vc.status = 3
            delegate?.selected(vc, type)
        }
        
        if indexPath.row == 6 {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()! as! ProfileEditViewController
            type = 2
            delegate?.selected(vc, type)
        }
        
        if indexPath.row == 7 {
            let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
            type = 2
            delegate?.selected(vc, type)
        }
        
        if indexPath.row == 8 {
            let vc = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController()! as! MenuViewController
            delegate?.selected(vc, type)
        }
        if indexPath.row == 9 {
            let vc = UIStoryboard(name: "Notice", bundle: nil).instantiateInitialViewController()! as! NoticeViewController
            type = 2
            delegate?.selected(vc, type)
        }
        if indexPath.row == 10 {
            let vc = UIStoryboard(name: "RankUp", bundle: nil).instantiateViewController(withIdentifier: "rankup") as! RankUpViewController
            delegate?.selected(vc, type)
        }
        if indexPath.row == 11 {
            let vc = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(withIdentifier: "wishEvent") as! WishViewController
            delegate?.selected(vc, type)
        }
        if indexPath.row == 12 {
            let vc = UIStoryboard(name: "Multiple", bundle: nil).instantiateViewController(withIdentifier: "MultipleType") as! MultipleTypeViewController
            vc.status = 6
            delegate?.selected(vc, type)
        }

        if indexPath.row != 0 {
            let cell = collectionView.cellForItem(at: indexPath) as! SideCell
            cell.badge.isHidden = true
        }
        
        if indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 8 {
            switch indexPath.row {
            case 3:
                userDefaults.removeObject(forKey: "footprint")
            case 4:
                userDefaults.removeObject(forKey: "like")
            case 8:
                userDefaults.removeObject(forKey: "notice")
            default:
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {

            if let roulette = userDefaults.object(forKey: "roulette") as! Int? {
                print("AAAルーレットルーレットルーレットルーレット", roulette)
                if roulette == 0 {
                    return CGSize(width:width, height: 0)
                } else {
                    return CGSize(width:width, height: 70)
                }
            }
        }
        return CGSize(width: (width/3)-7, height: 80)
    }
    
}
