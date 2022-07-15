//
//  BaseViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/11/20.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import Alamofire

class BaseViewController: UIViewController {
    private var requestAlamofire: Alamofire.Request?

    override func viewDidLoad() {
        super.viewDidLoad()
        let types = UIApplication.shared.enabledRemoteNotificationTypes()
        let osVersion = UIDevice.current.systemVersion
        updateUI()
        apiNoticeRequest()
    }

    override func viewDidAppear(_ animated: Bool) {
        apiNoticeRequest()
    }
    
    func apiNoticeRequest() {
        
        let onesignal_id = userDefaults.string(forKey: "fcmToken")?.isEmpty == false ? userDefaults.string(forKey: "fcmToken") : ""
        let parameters = [
            "onesignal_id": onesignal_id
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.baseGet, parameters: parameters,success: { [self] (response: ApiBaseParam) in
            var baseParam = response
            if (baseParam.status == 0) {
                let storyboard: UIStoryboard = self.storyboard!
                let multiple = storyboard.instantiateViewController(withIdentifier: "profile")
                multiple.modalPresentationStyle = .fullScreen
                self.present(multiple, animated: false, completion: nil)
            }
                
            let userDefaults = UserDefaults.standard
            var login_step_0 = userDefaults.object(forKey: "login_step_0") as? String

            if (login_step_0 != "1") {
                let storyboard: UIStoryboard = self.storyboard!
                let multiple = storyboard.instantiateViewController(withIdentifier: "term")
                self.present(multiple, animated: false, completion: nil)
            }
            
//            print("プロフィーーーーーーーーーーーーーーーー")
//            dump(baseParam)

            userDefaults.set(baseParam.api_token, forKey: "api_token")
            userDefaults.set(baseParam.status, forKey: "status")
            userDefaults.set(baseParam.point, forKey: "point")
            userDefaults.set(baseParam.notice, forKey: "notice")
            userDefaults.set(baseParam.tweet, forKey: "tweet")
            userDefaults.set(baseParam.like, forKey: "like")
            userDefaults.set(baseParam.match, forKey: "match")
            userDefaults.set(baseParam.footprint, forKey: "footprint")
            userDefaults.set(baseParam.join_group, forKey: "join_group")
            userDefaults.set(baseParam.rank, forKey: "rank")
            userDefaults.set(baseParam.user_name, forKey: "user_name")
            userDefaults.set(baseParam.profile_image, forKey: "profile_image")
            
            userDefaults.set(0, forKey: "roulette")
            if baseParam.roulette != nil {
                userDefaults.set(baseParam.roulette, forKey: "roulette")
            }
            
            if let tabBarItem = self.tabBarController?.tabBar.items?[1] as? UITabBarItem {
                tabBarItem.badgeValue = nil
            }
            if let tabBarItem = self.tabBarController?.tabBar.items?[2] as? UITabBarItem {
                tabBarItem.badgeValue = nil
            }
            if let tabBarItem = self.tabBarController?.tabBar.items?[3] as? UITabBarItem {
                tabBarItem.badgeValue = nil
            }
            if let tabBarItem = self.tabBarController?.tabBar.items?[4] as? UITabBarItem {
                tabBarItem.badgeValue = nil
            }
            if (baseParam.tweet != 0) {
                if let tabItem = self.tabBarController?.tabBar.items?[1] {
                    tabItem.badgeValue = "N"
                }
            }
                
//                if baseParam.join_group != 0 {
//                    if let tabItem = self.tabBarController?.tabBar.items?[3] {
//                        tabItem.badgeValue = "N"
//                    }
//                }

            if baseParam.message != 0 || baseParam.match != 0 {
                if let tabItem = self.tabBarController?.tabBar.items?[4] {
                    tabItem.badgeValue = "N"
                }
            }
            if (baseParam.notice != 0 || baseParam.like != 0 || baseParam.footprint != 0) {
                var total = baseParam.notice + baseParam.like  + baseParam.footprint
                print("ベーーーーーす", String(total), baseParam.notice, baseParam.like, baseParam.footprint)
                userDefaults.set(String(total), forKey: "sidemenu")
            } else {
                userDefaults.removeObject(forKey: "sidemenu")
            }
        
        
        },
        failure: { [self] error in
            print(error)
            print("アクセス失敗アクセス失敗アクセス失敗アクセス失敗アクセス失敗アクセス失敗")
            //  リクエスト失敗 or キャンセル時
            let alert = UIAlertController(title: "アクセス失敗", message: "しばらくお待ちください", preferredStyle: .alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            self.present(alert, animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            })
            return;
        }
        )
    }

    func updateUI() {
        guard let types = UIApplication.shared.currentUserNotificationSettings?.types else {
            return
        }
        switch types {
        case [.badge, .alert]:
            print("11111")
        case [.badge]:
            print("22222")
        case []:
            print("33333")
        default:
            print(types)
            print("Handle the default case") //TODO
        }
    }
}

