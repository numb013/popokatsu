//
//  ModalViewController.swift
//
//  Created by 中村篤史 on 2020/09/26.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST
import Alamofire
import AuthenticationServices
import Swifter

struct loginParam: Codable {
    let id: Int
    let api_token: String
    let hash_id: String
    let is_user: Int
    let status: Int
    let sex: Int
}

@available(iOS 13.0, *)
class LoginModalViewController: UIViewController, LoginButtonDelegate, UIViewControllerTransitioningDelegate {

    private var requestAlamofire: Alamofire.Request?;
    var userProfile : NSDictionary = [:]
    var login_sns_type = ""
    var sns_id = ""
    var name = ""
    var email = ""
    var status = 0
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var topImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = UILabel()
        title.frame = CGRect(x:((self.view.bounds.width-335)/2),y:30,width: 270,height:20)
        title.text = "SNSログイン / 新規登録"
        title.numberOfLines = 0;
//        label.sizeToFit()
        title.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8833208476)
        title.font = UIFont.boldSystemFont(ofSize:25.0)
        title.textColor = UIColor.popoTextColor
        title.textAlignment = NSTextAlignment.center
        view.addSubview(title)

        let detail = UILabel()
        detail.frame = CGRect(x:((self.view.bounds.width-335)/2),y:55,width: 270,height:85)
        detail.text = "SNSログインで新規登録をご利用になりますと別端末でも同じユーザで使用も可能になります。"
        detail.numberOfLines = 0;
        detail.font = UIFont.systemFont(ofSize:14.0)
        detail.textColor = UIColor.popoTextColor
        detail.textAlignment = NSTextAlignment.center
        view.addSubview(detail)

        // Facebookログイン用ボタンがSDKに用意されている
        let facebookLoginButton = FBLoginButton()
        // アクセス許可
        facebookLoginButton.permissions = ["public_profile", "email"]
        facebookLoginButton.center = self.view.center
        facebookLoginButton.delegate = self

        let twitterImage = UIImageView(image: UIImage(named: "Twitter"))
        twitterImage.isUserInteractionEnabled = true
        var recognizer1 = MyTapGestureRecognizer(target: self, action: #selector(self.onTapTwitter(_:)))
        twitterImage.addGestureRecognizer(recognizer1)
        
        let googleImage = UIImageView(image: UIImage(named: "googlelogin"))
        googleImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTapGoogle(_:)))
        googleImage.addGestureRecognizer(recognizer)

        let appleButton = ASAuthorizationAppleIDButton()

        facebookLoginButton.frame = CGRect(x:((self.view.bounds.width-335)/2),y:145,width:270,height:55)
        twitterImage.frame =        CGRect(x:((self.view.bounds.width-335)/2),y:210,width:270,height:55)
        googleImage.frame =         CGRect(x:((self.view.bounds.width-335)/2),y:275,width:270,height:55)
        appleButton.frame = CGRect(x:((self.view.bounds.width-335)/2),y:340,width:270,height:55)

        self.view.addSubview(twitterImage)
        self.view.addSubview(googleImage)
        self.view.addSubview(facebookLoginButton)
        // ログイン済みかチェック
        checkloginFacebook()

        if let user = GIDSignIn.sharedInstance()?.currentUser {
            print("currentUser.profile.email: \(user.profile!.email!)")
        } else {
            // 次回起動時にはこちらのログが出力される
            print("currentUser is nil")
        }

        appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.view.addSubview(appleButton)
    }

    // 3. 認証リクエスト
    @objc func handleAuthorizationAppleIDButtonPress() {
        // ASAuthorizationAppleIDRequestの作成
        let request = ASAuthorizationAppleIDProvider().createRequest()
        // Scopeの設定
        request.requestedScopes = [.email, .fullName]
        // ASAuthorizationControllerの作成
        let controller = ASAuthorizationController(authorizationRequests: [request])
        // Delegateの設定
        controller.delegate = self
        controller.presentationContextProvider = self
        // 認証リクエストを実行
        controller.performRequests()
    }

    /// ログイン済みかチェック
    func checkloginFacebook() {
        if let _ = AccessToken.current {
            print("Logged in")
        } else {
            print("Not Logged in")
        }
    }
    //    ログインコールバック
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        //エラーチェック
        if error == nil {
            //キャンセルしたかどうか
            if result.isCancelled {
            }else{
                returnUserData()
            }
        }else{
        }
    }
    //    ログアウトコールバック
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        print("ログアウトコールバックログアウトコールバックログアウトコールバック")
    }

    //twitterログイン
    @objc func onTapTwitter(_ sender: MyTapGestureRecognizer) {

        let swifter = Swifter(consumerKey: "48093gZGYB2kcfZfQMCV3bWCu", consumerSecret: "vRj14C1Fl5h4jLzmVC28DH6dwC79DMO7FeQKeDzc4xm8ShKV2O")

        swifter.authorize(
            withCallback: URL(string: "popokatsu://")!,
            presentingFrom: self,
            success: { accessToken, response in
                guard let accessToken = accessToken else { return }

                dump(accessToken)
                print("accessToken.key", accessToken.key)
                print("accessToken.secret", accessToken.secret)
                print("accessToken.userID", accessToken.userID)
                print("accessToken.screenName", accessToken.screenName)
                
                self.login_sns_type = "4"
                self.sns_id = accessToken.userID!
                self.name = accessToken.screenName!
                self.email = ""
                
                self.apiLoginCheck()
            }, failure: { error in
                print("エラーーーー", error)
            }
        )
    }

    //googleログイン
    @objc func onTapGoogle(_ sender: MyTapGestureRecognizer) {
        GIDSignIn.sharedInstance()?.delegate = self
        // ログイン画面の表示元を設定
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if GIDSignIn.sharedInstance()!.hasPreviousSignIn() {
            // 以前のログイン情報が残っていたら復元する
            GIDSignIn.sharedInstance()!.restorePreviousSignIn()
        } else {
            // 通常のログインを実行
            GIDSignIn.sharedInstance()?.signIn()
        }
    }

    //FBログイン
    func returnUserData()
    {
        let graphRequest : GraphRequest = GraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
            graphRequest.start(completionHandler: {
            (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // エラー処理
                print("Error: \(error)")
            } else {
                // エラー処理
                self.userProfile = result as! NSDictionary
                self.login_sns_type = "1"
                self.sns_id = (self.userProfile.object(forKey: "id") as? String)!
                self.name = (self.userProfile.object(forKey: "name") as? String)!
                if ((self.userProfile.object(forKey: "email")) != nil) {
                    self.email = (self.userProfile.object(forKey: "email") as? String)!
                }

                self.apiLoginCheck()
            }
        })
    }

   func apiLoginCheck() {

       let parameters = [
        "name": self.name,
        "email": self.email,
        "login_sns_type": self.login_sns_type,
        "sns_id": self.sns_id,
        "onesignal_id": userDefaults.string(forKey: "fcmToken")!,
       ] as [String:Any]
       
       print("ログインログインログインログインログインログインログイン")

       API.requestHttp(POPOAPI.base.userAdd, parameters: parameters,success: { [self] (response: loginParam) in
           self.status = response.status
           if self.status == 1 || self.status == 0 {
                let userDefaults = UserDefaults.standard
                userDefaults.set(response.api_token, forKey: "api_token")

                if (response.is_user == 1) {
                    userDefaults.set(response.sex, forKey: "sex")
                    self.userDefaults.set("1", forKey: "login_step_2")
                    let parentVC = self.presentingViewController as! FBLoginViewController
                    self.userDefaults.set(1, forKey: "status")
                    parentVC.updateView(type: 1)
                    //自分を閉じる
                    self.dismiss(animated: true, completion: nil)
                } else {
                    //画面遷移
                    let parentVC = self.presentingViewController as! FBLoginViewController
                    parentVC.updateView(type: 2)
                    //自分を閉じる
                    self.dismiss(animated: true, completion: nil)
                }
           } else {
                let alert = UIAlertController(title: "アカウントが無効です", message: "申し訳ございませんが、ご利用停止にさせていただいています", preferredStyle: .alert)
                let backView = alert.view.subviews.last?.subviews.last
                backView?.layer.cornerRadius = 15.0
                backView?.backgroundColor = .white
                self.present(alert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
           }
           },
           failure: { [self] error in
               //  リクエスト失敗 or キャンセル時
               let alert = UIAlertController(title: "アクセスエラー", message: "しばらくお待ちください", preferredStyle: .alert)
               let backView = alert.view.subviews.last?.subviews.last
               backView?.layer.cornerRadius = 15.0
               backView?.backgroundColor = .white
               self.present(alert, animated: true, completion: {
                   DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                       alert.dismiss(animated: true, completion: nil)
                   })
               })
               return;
           }
       )
   }
}

// GIDSignInDelegateへの適合とメソッドの追加を行う
@available(iOS 13.0, *)
extension LoginModalViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            // ログイン成功した場合
            self.login_sns_type = "2"
            self.sns_id = user!.userID
            self.name = user!.profile!.name
            self.email = user!.profile!.email!
            apiLoginCheck()
            let service = GTLRDriveService()
            service.authorizer = user.authentication.fetcherAuthorizer()
        } else {
            // ログイン失敗した場合
            print("error: \(error!.localizedDescription)")
        }
    }
}

@available(iOS 13.0, *)
extension LoginModalViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// 4. ハンドリング
@available(iOS 13.0, *)
extension LoginModalViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard
                let authCodeData = appleIDCredential.authorizationCode,
                let authCode = String(data: authCodeData, encoding: .utf8),
                let email = appleIDCredential.email,
                let idTokenData = appleIDCredential.identityToken,
                let idToken = String(data: idTokenData, encoding: .utf8),
                let fullName = appleIDCredential.fullName else {
                    print(appleIDCredential.user)
                    if appleIDCredential.user != nil {
                        userDefaults.set(appleIDCredential.user, forKey: "apple_user_id")
                        self.sns_id = appleIDCredential.user
                        self.login_sns_type = "3"
                        apiLoginCheck()
                    }
                    print("Problem with the authorizationCode")
                    return
                }
            print("authorization code : \(authCode)")
            print("identity token : \(idToken)")
            print("full name : \(fullName)")

            self.login_sns_type = "3"
            self.sns_id = appleIDCredential.user
            self.name = "\(fullName)"
            self.email = email
            userDefaults.set(appleIDCredential.user, forKey: "apple_user_id")

            apiLoginCheck()
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // 既存のiCloud Keychainクレデンシャル情報
            let username = passwordCredential.user
            let password = passwordCredential.password
            // 取得した情報を元にアカウントの作成などを行う
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization Failed: \(error)")
    }
}
