//
//  AppDelegate.swift
//  matchness
//
//  Created by user on 2019/02/05.
//  Copyright © 2019年 a2c. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseMessaging
import UserNotifications
import Alamofire
import SwiftyJSON
import FacebookCore //in theory is just this one
import FBSDKCoreKit
//import FBSDKShareKit
import GoogleSignIn
import AuthenticationServices
import StoreKit
import GoogleMobileAds
import IQKeyboardManagerSwift

import Swifter
import Siren

//import AppTrackingTransparency
//import AdSupport
let userDefaults = UserDefaults.standard

@available(iOS 13.0, *)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, PurchaseManagerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "term")
//        //rootViewControllerに入れる
//        self.window?.rootViewController = initialViewController
//        //表示
//        self.window?.makeKeyAndVisible()
//        return true
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        //特定のコントローラーを無効化
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(ChatMessageViewController.self)
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        var apple_user_id = userDefaults.object(forKey: "apple_user_id") as? String
        appleIDProvider.getCredentialState(forUserID: apple_user_id ?? "") {(credentialState, error) in
            switch credentialState {
            case .authorized:
//                DispatchQueue.main.async {
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "start")
//                    //rootViewControllerに入れる
//                    self.window?.rootViewController = initialViewController
//                    self.window?.makeKeyAndVisible()
//                }
            break // The Apple ID credential is valid.
            case .revoked, .notFound:
                print("The Apple ID credential is valid")
                break
            default:
                break
            }
        }

        //////////////// ▼▼ 追加 ▼▼ ////////////////
        //---------------------------------------
        // アプリ内課金設定
        //---------------------------------------
        // デリゲート設定
        PurchaseManager.sharedManager().delegate = self
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.sharedManager())
        //////////////// ▲▲ 追加 ▲▲ ////////////////

        // Override point for customization after application launch.
        var api_key = userDefaults.object(forKey: "api_token") as? String
        // Client IDを設定する
        GIDSignIn.sharedInstance()?.clientID = ApiConfig.FIREBASE_CLIENTID

//                self.window = UIWindow(frame: UIScreen.main.bounds)
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "applepay")
//                //rootViewControllerに入れる
//                self.window?.rootViewController = initialViewController
//                //表示
//                self.window?.makeKeyAndVisible()
//                return true

        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        

        if (api_key == nil || api_key == "") {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "fblogin")
            //rootViewControllerに入れる
            self.window?.rootViewController = initialViewController
            //表示
            self.window?.makeKeyAndVisible()
            return true
        }
        
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // sirenの強制アップデート設定用関数
        forceUpdate()
        
        return true
    }

    //////////////// ▼▼ 追加 ▼▼ ////////////////
    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")
        // TODO: コンテンツ解放処理
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //////////////// ▲▲ 追加 ▲▲ ////////////////
    
    func application(_ application: UIApplication,open url: URL,sourceApplication: String?,annotation: Any) -> Bool {
        print("きてるきてるきてるきてるきてる？")
//        applicationHandle(url: url)
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //////////////// ▼▼ 追加 ▼▼ ////////////////
        // オブザーバー登録解除
        SKPaymentQueue.default().remove(PurchaseManager.sharedManager());
        //////////////// ▲▲ 追加 ▲▲ ////////////////
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    // 追加する
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // GIDSignInのhandle()を呼び、返り値がtrueであればtrueを返す
        if GIDSignIn.sharedInstance()!.handle(url) {
            return true
        } else {
            return Swifter.handleOpenURL(url, callbackURL: URL(string: "popokatsu://")!)
        }
        return false
    }
    



//    func requestIDFA() {
//      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//        // Tracking authorization completed. Start loading ads here.
//        // loadAd()
//      })
//    }

}


@available(iOS 13, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler([])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler()
    }
}

private extension AppDelegate {
    func forceUpdate() {
        let siren = Siren.shared
        // 言語を日本語に設定
        siren.presentationManager = PresentationManager(forceLanguageLocalization: .japanese)
        // ruleを設定
        siren.rulesManager = RulesManager(globalRules: .critical)

        // sirenの実行関数
        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        // 以下のように、完了時の処理を無視して記述することも可能
        // siren.wail()
    }
}
