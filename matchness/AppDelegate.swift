//
//  AppDelegate.swift
//  matchness
//
//  Created by user on 2019/02/05.
//  Copyright © 2019年 a2c. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import FacebookCore //in theory is just this one
import FBSDKCoreKit
import GoogleSignIn
import AuthenticationServices
import StoreKit
import GoogleMobileAds
import IQKeyboardManagerSwift
import Swifter
import Siren


let userDefaults = UserDefaults.standard

@available(iOS 13.0, *)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, PurchaseManagerDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        print("きてる？？？？？？")
        FirebaseApp.configure()
        //③FirebaseMessagingDelegateに登録
        Messaging.messaging().delegate = self
        //④リモート通知に登録
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()


        // プッシュ通知のアイコンに表示されるバッチを消す処理 TODO：どこでこの処理するか
         UIApplication.shared.applicationIconBadgeNumber = 0


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

        //---------------------------------------
        // アプリ内課金設定
        //---------------------------------------
        // デリゲート設定
        PurchaseManager.sharedManager().delegate = self
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.sharedManager())

        // Override point for customization after application launch.
        var api_key = userDefaults.object(forKey: "api_token") as? String
        // Client IDを設定する
        GIDSignIn.sharedInstance()?.clientID = ApiConfig.FIREBASE_CLIENTID
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

    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")
        // TODO: コンテンツ解放処理
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    //MARK: - Remote Notification
    //④リモート通知に登録を実施した時の処理を実装
    //プッシュ通知を受け取った時の処理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //バックグラウンドに取得した通知をフェッチする
        completionHandler(UIBackgroundFetchResult.newData)
    }
    //リモート通知の登録に失敗した時に呼ばれる
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("失敗失敗失敗失敗unable to register for remote notigications",error.localizedDescription)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // コンソールに登録トークンを出力する
        print("Firebase registration token: \(String(describing: fcmToken))")
        userDefaults.set(fcmToken!, forKey: "fcmToken")
        // 登録トークンが新規の場合、アプリケーションサーバーに送信
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }

    // APNsより登録デバイストークンを取得し、コンソールに出力する（デバッグ用）
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print("APNs token retrieved: \(deviceToken)")

      //　メソッド実装入れ替えをしない場合、APNs発行のデバイストークンとFCM発行デバイストークンを明示的にマッピングする必要があります。
      // Messaging.messaging().apnsToken = deviceToken
    }
  
    
    
    
    func application(_ application: UIApplication,open url: URL,sourceApplication: String?,annotation: Any) -> Bool {
        print("きてるきてるきてるきてるきてる？")
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // オブザーバー登録解除
        SKPaymentQueue.default().remove(PurchaseManager.sharedManager());
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
    }
}


//④プッシュ通知を受け取ったときの処理
extension AppDelegate:UNUserNotificationCenterDelegate{
    //プッシュ通知を受け取るための関数
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //必ず実行すること
        completionHandler()
    }
}

