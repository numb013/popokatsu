//
//  UserSearchViewController.swift
//  matchness
//
//  Created by user on 2019/02/05.
//  Copyright © 2019年 a2c. All rights reserved.
//

import UIKit
//import Alamofire
//import SwiftyJSON
import SDWebImage
import FBSDKCoreKit
import FBSDKLoginKit
import DZNEmptyDataSet
import HealthKit
import Koloda
import PagingMenuController
import GoogleMobileAds
import SafariServices
import AdSupport
import AppTrackingTransparency
import SideMenu


struct pickup: Codable {
    let id: Int?
    let hash_id: String?
    let name: String?
    let work: Int?
    let sex: Int?
    let blood_type: Int?
    let point: Int?
    let birthday: String?
    let prefecture_id: Int?
    let profile_text: String?
    let fitness_parts_id: Int?
    let created_at: String?
    let profile_image: String?
    let age: Int?
}

@available(iOS 13.0, *)
class UserSearchViewController: BaseViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var dataSource = [ApiUserDate]()
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    let kolodaView = KolodaView()
    let close_button = UIButton()
    private var myImageView: UIImageView!
    let view_1 = UIView()
    var activityIndicatorView = UIActivityIndicatorView()
    let userDefaults = UserDefaults.standard

    var page_no = 1
    var isUpdate:Bool = false
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    let width: CGFloat = UIScreen.main.bounds.width / 2.07
    var refreshControl:UIRefreshControl!
    let store = HKHealthStore()
    var Koloda_flag = 0
    var like_id:Int = 0
    var pick_up_list: Array<pickup> = Array<pickup>();
    var sideMenu: SideMenuNavigationController?
    let menuButton = SSBadgeButton()
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        var api_key = userDefaults.object(forKey: "api_token") as? String
        super.viewDidLoad()

        
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes: Set<HKObjectType> = [
             HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!
            ]
            // 許可されているかどうかを確認
            store.requestAuthorization(toShare: nil, read: readDataTypes as? Set<HKObjectType>) {
                (success, error) -> Void in
            }
        } else{
            Alert.helthError(alertNum: self.errorData, viewController: self)
        }
        

        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        

//        var contentVM = StepMaster()
//        contentVM.get(
//            dateFormatter.date(from: "2022/02/01 00:00:00")!,
//            dateFormatter.date(from: "2022/02/05 23:59:59")!
//        )
//        DispatchQueue.main.async { [self] in
//            print("歩数歩数歩数歩数歩数歩数歩数", contentVM.count)
//        }

        
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                print("拒否")
            case .restricted:
                print("制限")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        } else {// iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("制限")
            }
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
 

        view.backgroundColor = .lightGray
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)

        self.collectionView.register(UINib(nibName: "UserSearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "userDetailCell")
        // Do any additional setup after loading the view.


        //UIRefreshControllのインスタンスを生成する。
        self.refreshControl = UIRefreshControl()
        //下に引っ張った時に、リフレッシュさせる関数を実行する。”：”を忘れがちなので注意。
        self.refreshControl?.addTarget(self, action: "refresh", for: UIControl.Event.valueChanged)
        //UICollectionView上に、ロード中...を表示するための新しいビューを作る
        collectionView.addSubview(self.refreshControl)
        self.navigationItem.title = "さがす"

        collectionView.contentInset.bottom = 80

        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        let tabBarController: UITabBarController = UITabBarController()
        let tabBarHeight = tabBarController.tabBar.frame.size.height
        bannerView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - tabBarHeight - bannerView.frame.height)
        bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
        
        bannerView.adUnitID = ApiConfig.ADUNIT_ID // 本番
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // テスト
        bannerView.rootViewController = self;
        let request = GADRequest();
        bannerView.load(request)
        addBannerViewToView(bannerView)
    }
    ///Alert表示
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    
    
    
    //上に引っ張る更新
    @objc func refresh() {
        self.isUpdate = false
        self.page_no = 1
        dataSource = []
        apiRequest()
        self.refreshControl?.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (userDefaults.object(forKey: "status") == nil) {
             let storyboard: UIStoryboard = self.storyboard!
             let multiple = storyboard.instantiateViewController(withIdentifier: "profile")
             multiple.modalPresentationStyle = .fullScreen
             self.present(multiple, animated: false, completion: nil)
             return
        }

         if (userDefaults.object(forKey: "login_step_0") as? String != "1") {
             let storyboard: UIStoryboard = self.storyboard!
             let multiple = storyboard.instantiateViewController(withIdentifier: "term")
             self.present(multiple, animated: false, completion: nil)
             return
         }
        
         if (userDefaults.object(forKey: "login_step_1") as? String != "1") {
             let vc = TutorialView()
             self.present(vc, animated: false, completion: nil)
             return
         }

        self.navigationItem.title = "さがす"
        //タブバー表示
        tabBarController?.tabBar.isHidden = false
         
        
        self.isUpdate = false
        if userDefaults.object(forKey: "searchOnOff") as? Int == 1 {
            self.page_no = 1
            dataSource = []
            apiRequest()
            self.refreshControl?.endRefreshing()
            UserDefaults.standard.set(0, forKey: "searchOnOff")
        } else {
            apiRequest()
            apiRequestPickUp()
        }
    }
    
    // 画面に表示された直後に呼ばれます。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //サイドメニューセット
        sideMenuButtonSet()
        print("viewDidAppear")
    }
    
    func sideMenuButtonSet() {
        menuButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        menuButton.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if userDefaults.object(forKey: "sidemenu") != nil {
            menuButton.badgeEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)
            menuButton.badge = userDefaults.string(forKey: "sidemenu")
        }
        menuButton.addTarget(self,action: #selector(self.sideMenu(_ :)),for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    @objc func sideMenu(_ sender: UIBarButtonItem) {
        menuButton.badgeLabelHidden()
        print("メニュータップ")
        sideMenu = SideMenuNavigationController(rootViewController: SideMenuController())
        sideMenu!.leftSide = false
        //メニューの陰影度
        sideMenu!.presentationStyle.onTopShadowOpacity = 0.9
        //メニューの動き
        sideMenu!.presentationStyle = .viewSlideOutMenuIn
        //メインの透明度
        sideMenu!.presentationStyle.presentingEndAlpha = 0.2

        sideMenu!.menuWidth = 320
        
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)

        present(sideMenu!, animated: true)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 2  >= collectionView.contentSize.height - self.collectionView.bounds.size.height) && isUpdate == true {
            isUpdate = false
            self.page_no += 1
            apiRequest()
        }
    }

    //データの個数を返すメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.dataSource.count
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14.0)
        ]
        return NSAttributedString(string: "データがありません", attributes:stringAttributes)
    } 

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("SSSSSSSSSSS", self.dataSource.count, indexPath.row)
        

        let cell : UserSearchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "userDetailCell", for: indexPath as IndexPath) as! UserSearchCollectionViewCell

        if self.dataSource.count == 0 {
            return cell
        }
        var search = self.dataSource[indexPath.row]
        var age_text = String(search.age)

        if (search != nil) {
            cell.agearea.text = search.name
            cell.job.text = age_text + "歳 / " + ApiConfig.PREFECTURE_LIST[search.prefecture_id]
            cell.tag = search.id ?? 0
            if (search.profile_image == nil) {
                cell.imageView.image = UIImage(named: "no_image")
            } else {
                let profileImageURL = image_url + search.profile_image
                cell.imageView.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
            }
            //新規登録
            cell.new_flag.isHidden = true
            if (search.created_flag != nil) {
                if (search.created_flag == 1) {
                    cell.new_flag.image = UIImage(named: "new1")
                    cell.new_flag.isHidden = false
                }
                if (search.created_flag == 2) {
                    cell.new_flag.image = UIImage(named: "new2")
                    cell.new_flag.isHidden = false
                }
            } else {
                if (search.rank != 0) {
                    cell.new_flag.isHidden = false
                    if (search.rank == 1) {
                        cell.new_flag.image = UIImage(named: "bronze")
                    }
                    if (search.rank == 2) {
                        cell.new_flag.image = UIImage(named: "silver")
                    }
                    if (search.rank == 3) {
                        cell.new_flag.image = UIImage(named: "gold")
                    }
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 例えば端末サイズの半分の width と height にして 2 列にする場合
//        let width: CGFloat = UIScreen.main.bounds.width / 2.025
        let height = width + 50
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        var user_id = selectedCell?.tag ?? 0
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "toDetail" {
            let udc:UserDetailViewController = segue.destination as! UserDetailViewController
            udc.user_id = sender as! Int
        }
    }
        
    @IBAction func searchButton(_ sender: Any) {
        searchButton.isEnabled = true
        self.performSegue(withIdentifier: "searchButton", sender: nil)
    }

    @IBAction func nextButton(_ sender: Any) {
        let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
//        let vc = UIStoryboard(name: "Roulette", bundle: nil).instantiateViewController(withIdentifier: "RouletteList") as! RouletteListViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func apiRequest() {
        let parameters = [
            "page": page_no,
            "freeword": userDefaults.object(forKey: "searchFreeword"),
            "work": userDefaults.object(forKey: "searchWork"),
            "age_id": userDefaults.object(forKey: "searchAgeId"),
            "prefecture_id": userDefaults.object(forKey: "searchPrefectureId"),
            "blood_type": userDefaults.object(forKey: "searchBloodType"),
            "sex": userDefaults.object(forKey: "searchSex"),
            "fitness_parts_id": userDefaults.object(forKey: "searchFitnessPartsId"),
        ] as! [String:Any]
        
        API.requestHttp(POPOAPI.base.userSearch, parameters: parameters,success: { [self] (response: [ApiUserDate]) in
                isUpdate = response.count < 5 ? false : true
//                    print("更新更新更新更新更新更新更新更新", isUpdate, response.count)
                dataSource.append(contentsOf: response)
                self.activityIndicatorView.stopAnimating()
                collectionView.reloadData()
            },
            failure: { [self] error in
                print(error)
                // self.errorData = model.errorData;
                // Alert.common(alertNum: self.errorData, viewController: self)
            }
        )
    }

    func apiRequestPickUp() {
        API.requestHttp(POPOAPI.base.userPickUp, parameters: nil,success: { [self] (response: [pickup]) in
            self.pick_up_list = response

            if (!self.pick_up_list.isEmpty) {
                tabBarController?.tabBar.isHidden = true
                self.searchButton.isEnabled = false
                view_1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                view_1.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4566299229)
                view_1.center = self.view.center
                self.view.addSubview(view_1)
                
                // ボタンのインスタンス生成
                if UIScreen.main.nativeBounds.height >= 1792 {
                    close_button.frame = CGRect(x: -10, y: 80, width: 70, height: 70)
                } else {
                    close_button.frame = CGRect(x: -5, y: 60, width: 50, height: 50)
                }
                close_button.addTarget(self, action: #selector(self.close(_:)), for: .touchUpInside)
                let picture = UIImage(named: "close")
                close_button.setImage(picture, for: .normal)
                self.view.addSubview(close_button)
                
                kolodaView.dataSource = self
                kolodaView.delegate = self
                if (self.Koloda_flag == 1) {
                    kolodaView.reloadData()
                }
                kolodaView.frame = CGRect(x: 0, y: 0, width: 320, height: 470)
                kolodaView.center = self.view.center
                self.view.addSubview(kolodaView)
                self.Koloda_flag = 1
            }
            },
            failure: { [self] error in
                print(error)
                // self.errorData = model.errorData;
                // Alert.common(alertNum: self.errorData, viewController: self)
            }
        )
    }
    
    func apiSwipeLikeRequest(type:Int, like_id:Int) {
        let parameters = [
            "type": type,
            "target_id": like_id
        ] as! [String:Any]
        
        API.requestHttp(POPOAPI.base.createSwipeLike, parameters: parameters,success: { [self] (response: ApiStatus) in

            },
            failure: { [self] error in
                print(error)
                // self.errorData = model.errorData;
                // Alert.common(alertNum: self.errorData, viewController: self)
            }
        )
    }
}

//MARK:- KolodaViewDataSource
@available(iOS 13.0, *)
extension UserSearchViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return self.pick_up_list.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        // Card.
        self.like_id = self.pick_up_list[index].id!

        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 1.5)

        myImageView = UIImageView(frame: CGRect(x:0, y:0, width:320, height:320))
        let profileImageURL = ApiConfig.REQUEST_URL_IMEGE + self.pick_up_list[index].profile_image!
        myImageView.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        view.addSubview(myImageView)
        
        let title = UILabel()
        title.frame = CGRect(x:0,y:0,width: 320,height:30)
        title.text = "本日のPickupメンバー"
//        label.sizeToFit()
        title.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8833208476)
        title.font = UIFont.systemFont(ofSize:14.0)
        title.textColor = #colorLiteral(red: 0.3277077377, green: 0.3560283184, blue: 0.3939625323, alpha: 1)
        title.textAlignment = NSTextAlignment.center
        view.addSubview(title)
        
        
        let label = UILabel()
        label.frame = CGRect(x:0,y:330,width: 320,height:50)
        var name_title =  self.pick_up_list[index].name! + " / " + String(self.pick_up_list[index].age!) + "歳 / " + ApiConfig.PREFECTURE_LIST[self.pick_up_list[index].prefecture_id!]
        label.text = name_title
//        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize:17.0)
        label.textColor = #colorLiteral(red: 0.3277077377, green: 0.3560283184, blue: 0.3939625323, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)

        // ボタンのインスタンス生成
        let button = UIButton()
        button.frame = CGRect(x: 20, y: 385, width: 130, height: 50)
        button.setTitle("スキップ", for:UIControl.State.normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 16)
        button.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
        button.addTarget(self, action: #selector(self.cardGoToNope(_:)), for: .touchUpInside)
        view.addSubview(button)

        // ボタンのインスタンス生成
        let button_1 = UIButton()
        button_1.frame = CGRect(x: 165, y: 385, width: 130, height: 50)
        button_1.setTitle("いいね", for:UIControl.State.normal)
        button_1.titleLabel?.font =  UIFont.systemFont(ofSize: 16)
        button_1.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        button_1.addTarget(self, action: #selector(self.cardGoToLike(_:)), for: .touchUpInside)
        view.addSubview(button_1)
        return view
    }
    
    @objc func cardGoToNope(_ sender : Any) {
        kolodaView.swipe(.left)
     }
    @objc func cardGoToLike(_ sender : Any) {
        kolodaView.swipe(.right)
     }
}

//MARK:- KolodaViewDelegate
@available(iOS 13.0, *)
extension UserSearchViewController: KolodaViewDelegate {
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left, .right]
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //urlに飛べる
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = self.pick_up_list[index].id!
        navigationController?.pushViewController(vc, animated: true)
    }
    //darag中に呼ばれる
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        return true
    }
    //dtagの方向など
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction.rawValue == "right" {
            apiSwipeLikeRequest(type: 1, like_id : self.pick_up_list[index].id!)
        } else {
            apiSwipeLikeRequest(type: 0, like_id : self.pick_up_list[index].id!)
        }
    }

    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        self.view_1.removeFromSuperview()
        close_button.removeFromSuperview()
        koloda.removeFromSuperview()
        kolodaView.resetCurrentCardIndex()
        tabBarController?.tabBar.isHidden = false
        self.searchButton.isEnabled = true
    }
    @objc func close(_ sender : Any) {
        self.view_1.removeFromSuperview()
        close_button.removeFromSuperview()
        kolodaView.removeFromSuperview()
        kolodaView.resetCurrentCardIndex()
        tabBarController?.tabBar.isHidden = false
        self.searchButton.isEnabled = true
     }
}

