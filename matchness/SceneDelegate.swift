
import UIKit
import Swifter


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if #available(iOS 13.0, *) {
            guard let _ = (scene as? UIWindowScene) else { return }
        } else {
            // Fallback on earlier versions
        }
    }
    // callback urlの設定
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>){
        print("URLContexts", URLContexts)
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneが閉じられるよ") //<- 書き足した
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneがactiveになったよ") //<- 書き足した
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneがinactiveになったよ") //<- 書き足した
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneがforegroundにきたよ") //<- 書き足した
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneがbackgroundになったよ") //<- 書き足した
    }
}
