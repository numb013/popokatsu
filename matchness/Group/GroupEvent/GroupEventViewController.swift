//
//  GroupEventViewController.swift
//  matchness
//
//  Created by user on 2019/06/22.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
import HealthKit
import SDWebImage

class GroupEventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak internal var eventTime: UILabel!
    @IBOutlet weak internal var peopleNumber: UILabel!
    @IBOutlet weak internal var rank: UILabel!
    @IBOutlet weak internal var stepNumber: UILabel!
    @IBOutlet weak internal var tableView: UICollectionView!
    var badgeCount = Int()
    var group_step:Int = 0
    var status = 0
    var dataSource = [ApiGroupEvent]()
    var dataGroupEvent = [ApiGroupEventList]()
    
    var dataSourceOrder: Array<String> = []
    var errorData: Dictionary<String, ApiErrorAlert> = [:]
    var cellCount: Int = 0
    let now = Date()
    var group_param = [String:Any]()
    let dateFormatter = DateFormatter()
    let store = HKHealthStore()
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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

        self.tableView.register(UINib(nibName: "GroupEventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "groupCell")
        tabBarController?.tabBar.isHidden = true
        getStepDate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.topItem!.title = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.apiRequestGroupEvent()
        self.navigationItem.title = ApiConfig.GROUP_LABEL[group_param["group_status"] as! Int]
    }

    func viewMain() {
        self.status = dataSource[0].status as! Int
        rank.text = "\(dataSource[0].rank!) 位"
        eventTime.text = dataSource[0].event_time
        peopleNumber.text = dataSource[0].event_peple
        stepNumber.text = "\(dataSource[0].step!)"

        if dataSource[0].chat_confirm == 1 {
            setUpBadgeCountAndBarButton()
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "チャット" ,style: .plain,target: self,action: #selector(actionDone(_:)))
        }
    }

    func setUpBadgeCountAndBarButton() {
        // badge label
        let label = UILabel(frame: CGRect(x: 70, y: -05, width: 25, height: 25))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.backgroundColor = .red
        label.text = "1"

        // button
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        rightButton.setBackgroundImage(UIImage(named: "group_chat"), for: .normal)
        rightButton.addTarget(self, action: #selector(actionDone(_:)), for: .touchUpInside)
        rightButton.addSubview(label)

        // Bar button item
        let rightBarButtomItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButtomItem
        
    }
    
    func getStepDate() {
        getDayStep { (result) in
            DispatchQueue.main.async {
                self.group_step = Int(result)
                self.apiRequestGroupEvent()
                // self.progressViewBar.value = (CGFloat(Double(result) / 10000)*100)
            }
        }
    }

    // 今日の歩数を取得するための関数
    func getDayStep(completion: @escaping (Double) -> Void) {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let startdate = dateFormater.date(from: group_param["start"] as! String)
        var component = NSCalendar.current.dateComponents([.year, .month, .day], from: startdate!)
        component.hour = 0
        component.minute = 0
        component.second = 0
        let start:NSDate = NSCalendar.current.date(from:component)! as NSDate

        let enddate = dateFormater.date(from: group_param["end"] as! String)
        var component_end = NSCalendar.current.dateComponents([.year, .month, .day], from: enddate!)
        //XX月XX日23時59分59秒に設定したものをendにいれる
        component_end.hour = 23
        component_end.minute = 59
        component_end.second = 59
        let end:NSDate = NSCalendar.current.date(from:component_end)! as NSDate

        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: start as Date, end: end as Date, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .separateBySource) { (query, data, error) in
            if let sources = data?.sources?.filter({ $0.bundleIdentifier.hasPrefix("com.apple.health") }) {
                let sourcesPredicate = HKQuery.predicateForObjects(from: Set(sources))
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sourcesPredicate])
                let query = HKStatisticsQuery(quantityType: type,
                                              quantitySamplePredicate: predicate,
                                              options: .cumulativeSum)
                { (query, statistics, error) in
                    var value: Double = 0
                    if error != nil {
                    } else if let quantity = statistics?.sumQuantity() {
                        value = quantity.doubleValue(for: HKUnit.count())
                        completion(value)
                    }
                }
                self.store.execute(query)
            }
        }
        store.execute(query)
    }

    func apiRequestGroupEvent() {
        /****************
         APIへリクエスト（ユーザー取得）
         *****************/
        let parameters = [
            "group_id": self.group_param["group_id"],
            "total_step": self.group_step,
            "status": group_param["status"]
        ] as [String:Any]
        
        API.requestHttp(POPOAPI.base.selectGroupEvent, parameters: parameters,success: { [self] (response: [ApiGroupEvent]) in
            dataSource = response
//            isUpdate = dataSource[0].group_event.count < 5 ? false : true
            dataGroupEvent = dataSource[0].group_event
            viewMain()
            tableView.reloadData()
            },
            failure: { [self] error in
                print(error)
            }
        )
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataGroupEvent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : GroupEventCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath as IndexPath) as! GroupEventCollectionViewCell
        let label = UILabel()
        var group_event = dataGroupEvent[indexPath.row]

        print(group_event)


        if (group_event.profile_image == nil) {
            cell.userImage.image = UIImage(named: "no_image")
        } else {
            let profileImageURL = image_url + group_event.profile_image
            cell.userImage.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        }
        
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.cornerRadius =  cell.userImage.frame.height / 2
        cell.userImage.isUserInteractionEnabled = true
        var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        recognizer.targetUserId = group_event.user_id
        cell.userImage.addGestureRecognizer(recognizer)
        cell.lastLoginTime.textColor = UIColor.white
        cell.userInfo.textColor = UIColor.white
        cell.userStep.textColor = UIColor.white
        cell.step.textColor = UIColor.white
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let date = dateFormater.date(from: group_event.action_datetime as! String)
        dateFormater.dateFormat = "MM/dd HH:mm"
        let date_text = dateFormater.string(from: date ?? Date())
        
        cell.lastLoginTime.text = "ログイン：" + date_text
        var name = group_event.name
        var age =  "\(group_event.age) 歳 "
        var prefecture = ApiConfig.PREFECTURE_LIST[group_event.prefecture_id ?? 0]

        cell.userInfo?.adjustsFontSizeToFitWidth = true
        cell.userInfo?.numberOfLines = 0
        cell.userInfo.text = name + " " + age + prefecture

        cell.userStep.text = "\(group_event.step)"
        cell.contentView.addSubview(label)
        
        if group_event.step ?? 0 < 15000 {
            cell.backgroundColor = .popoTextGreen
        } else {
            cell.backgroundColor = .popoPink
        }
        return cell
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        var user_id = sender.targetUserId!
        let vc = UIStoryboard(name: "UserDetail", bundle: nil).instantiateInitialViewController()! as! UserDetailViewController
        vc.user_id = user_id
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func actionDone(_ sender: UIButton) {
        let vc = GroupChat()
        vc.status = self.status
        vc.group_id = (self.group_param["group_id"] as? Int)!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let udc:UserDetailViewController = segue.destination as! UserDetailViewController
            udc.user_id = sender as! Int
        }
    }

}

extension GroupEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 例えば端末サイズの半分の width と height にして 2 列にする場合
        let width: CGFloat = UIScreen.main.bounds.width / 2.01
        let height: CGFloat = 90
        return CGSize(width: width, height: height)
    }
}
