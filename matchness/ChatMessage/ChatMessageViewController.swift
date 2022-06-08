//
//  ChatMessageViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/11/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit
import Firebase
import ImageViewer


class ChatMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatInputAccessoryViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryItemsDataSource {

    let userDefaults = UserDefaults.standard
    var message_users = [String:String]()
    private var messages = [Message]()
    let f = DateFormatter()
    var point = Int()
    var girl_message_point = 20
    var boy_message_point = 50
    var use_point = Int()
    var sex = String()
    @IBOutlet weak var tableView: UITableView!
    private let accessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    
    var galleyItem: GalleryItem!
    struct DataItem {
        let imageView: UIImage
        let galleryItem: GalleryItem
    }
    var items: [DataItem] = []
    func itemCount() -> Int {
        return items.count
    }
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
    private var presenter: ChatMessageInput!
    func inject(presenter: ChatMessageInput) {
        // このinputがpresenterのこと
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "やりとり"
        navigationController!.navigationBar.topItem!.title = message_users["target_name"]

        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
        
        let presenter = ChatMessagePresenter(view: self)
        inject(presenter: presenter)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupChatRoomTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ChatMessageCell", bundle: nil), forCellReuseIdentifier: "ChatMessageCell")
        self.tableView.register(UINib(nibName: "ChatImageCell", bundle: nil), forCellReuseIdentifier: "ChatImageCell")
        tableView.contentInset = tableViewContentInset
        tableView.scrollIndicatorInsets = tableViewIndicatorInset
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset.top = 30
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if keyboardFrame.height <= accessoryHeight { return }
            
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - tableView.contentOffset.y)
            // 最下部意外の時は少しずれるので微調整
            if tableView.contentOffset.y != -60 { moveY += 60 }
//            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
//            tableView.contentInset = contentInset
//            tableView.scrollIndicatorInsets = contentInset
            tableView.contentInset.top = top+90
            tableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    @objc func keyboardWillHide() {
        tableView.contentInset = tableViewContentInset
        tableView.scrollIndicatorInsets = tableViewIndicatorInset
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages() {
        print("FNiPCwNJbsLlroom_code", message_users["room_code"])
        guard let dccode = message_users["room_code"] else { return }
        Firestore.firestore().collection("messages").document(dccode).collection("chat").addSnapshotListener { [self] (querySnapshot, error) in
            guard let snapshots = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshots.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = StringToDate(dateValue: m1.create_at, format: "yyyy-MM-dd HH:mm:ss")
                        let m2Date = StringToDate(dateValue: m2.create_at, format: "yyyy-MM-dd HH:mm:ss")
                        return m1Date > m2Date
                    }

                    self.tableView.reloadData()
//                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)

                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    func StringToDate(dateValue: String, format: String) -> Date {
       let dateFormatter = DateFormatter()
       dateFormatter.calendar = Calendar(identifier: .gregorian)
       dateFormatter.dateFormat = format
       return dateFormatter.date(from: dateValue) ?? Date()
   }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var time = ""
        if indexPath.row != 0 {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let day1:Date = myDateFormatter.date(from: messages[indexPath.row].create_at)!
            let day2:Date = myDateFormatter.date(from: messages[indexPath.row-1].create_at)!
            let dayInterval = (Calendar.current.dateComponents([.day], from: day1, to: day2)).day
            
            if dayInterval != 0 {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ja_JP")
                dateFormatter.dateStyle = .medium
                dateFormatter.dateFormat = "MM月dd日"
                time = dateFormatter.string(from: StringToDate(dateValue: messages[indexPath.row-1].create_at, format: "yyyy-MM-dd HH:mm:ss"))
            }
        }
        
        
        if messages[indexPath.row].media_type == "text" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! ChatMessageCell
            cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
            cell.message = messages[indexPath.row]
            cell.message_users = message_users
            cell.dayIntervalView.isHidden = true
            cell.dayInterval.isHidden = true
            cell.dayInterval.text = time
            if time != "" {
                cell.dayIntervalView.isHidden = false
                cell.dayInterval.isHidden = false
                cell.dayInterval.text = time
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageCell") as! ChatImageCell
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messages[indexPath.row]
        cell.message_users = message_users
        cell.dayIntervalView.isHidden = true
        cell.dayInterval.isHidden = true
        cell.dayInterval.text = time
        if time != "" {
            cell.dayIntervalView.isHidden = false
            cell.dayInterval.isHidden = false
            cell.dayInterval.text = time
        }
        
        if messages[indexPath.row].from == message_users["user_id"] {
            cell.myPostImageView.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.indexRow = indexPath.row
            cell.myPostImageView.addGestureRecognizer(recognizer)
        } else {
            cell.partnerPostImageView.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            recognizer.indexRow = indexPath.row
            cell.partnerPostImageView.addGestureRecognizer(recognizer)
        }

        
        return cell
    }
    
    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        self.items = []
        let storage = Storage.storage()
        let host = "gs://popo-katsu-266622.appspot.com"

        storage.reference(forURL: host).child("images/").child(messages[Int(sender.indexRow!)].image_url!)
            .getData(maxSize: 3 * 1024 * 1024, completion: { [self] data, error in
                let imageData = data
                let image = UIImage(data: imageData!)
                galleyItem = GalleryItem.image{ $0(image) }
                items.append(DataItem(imageView: image!, galleryItem: galleyItem))
                DispatchQueue.main.async(execute: { [self] in
                    let galleryViewController = GalleryViewController(startIndex: 0, itemsDataSource: self, configuration: [.deleteButtonMode(.none), .seeAllCloseButtonMode(.none), .thumbnailsButtonMode(.none)])
                    self.present(galleryViewController, animated: true, completion: nil)

                })
            })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tappedSendButton(text: String) {
        self.point = self.userDefaults.object(forKey: "point") as! Int
        if self.sex == "1" {
            self.use_point = girl_message_point
        } else {
            self.use_point = boy_message_point
        }
        if self.point < self.use_point {
            let alertController:UIAlertController =
                UIAlertController(title:"メッセージを送信",message: "メッセージを送信には" + String(self.use_point) + "pt必要です",preferredStyle: .alert)
            let backView = alertController.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // Default のaction
            let defaultAction:UIAlertAction =
                UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
                    (action:UIAlertAction!) -> Void in
                    // 処理
                    print("ポイント変換ページへ")
                    self.tabBarController?.tabBar.isHidden = false
                    let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                })

            // Cancel のaction
            let cancelAction:UIAlertAction =
                UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                    (action:UIAlertAction!) -> Void in
                })
            defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
            cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
            // actionを追加
            alertController.addAction(cancelAction)
            alertController.addAction(defaultAction)
            // UIAlertControllerの起動
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.point = self.point - self.use_point
            self.userDefaults.set(Int(self.point), forKey: "point")
            self.addMessage(text)
            f.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var docData = [
                "name": self.message_users["user_name"],
                "text":text,
                "from": self.message_users["user_id"],
                "create_at": f.string(from: Date()),
                "media_type": "text"
            ] as [String : Any]
            addMessageToFirestore(docData)
        }
        
        self.view.endEditing(true)
    }
    
    private func addMessageToFirestore(_ docData: [String : Any]) {
        chatInputAccessoryView.removeText()
        let messageId = randomString(length: 20)

        guard let dccode = message_users["room_code"] else { return }
        Firestore.firestore().collection("messages").document(dccode).collection("chat").document(messageId).setData(docData) { (err) in
            if let err = err {
                return
            }
        }
    }
    
    func tappedPhotoButton() {
        selectImage()
    }

    private func selectImage() {
        let alertController: UIAlertController = UIAlertController(title:  "カメラへアクセス", message: "お使いの機能をお選び下さい", preferredStyle:  UIAlertController.Style.alert)
        //        let alertController = UIAlertController(title: "画像を選択", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラを起動", style: .default) { (UIAlertAction) -> Void in
            self.selectFromCamera()
        }
        let libraryAction = UIAlertAction(title: "カメラロールから選択", style: .default) { (UIAlertAction) -> Void in
            self.selectFromLibrary()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (UIAlertAction) -> Void in
            print("閉じる")
        }
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func selectFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラ許可をしていない時の処理")
        }
    }

    private func selectFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラロール許可をしていない時の処理")
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let resizedImage = self.resizeImage(image: info[UIImagePickerController.InfoKey.editedImage] as! UIImage, ratio: 0.9) // 90% に縮小
        let imageData = NSData(data: (resizedImage).pngData()!) as NSData
        let storageRef = Storage.storage().reference()

        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let messageId = randomString(length: 5)
        
        var image_url : String? = ""
        let referenceRef = storageRef.child("images/" + messageId + ".jpg")
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        referenceRef.putData(imageData as Data, metadata: meta, completion: { [self] metaData, error in
            if (error != nil) {
                print("Uh-oh, an error occurred!")
            } else {
                var text = ""
                self.addMessage(text)
                image_url = metaData?.name
                var docData = [
                    "name": self.message_users["user_name"],
                    "text":nil,
                    "from": self.message_users["user_id"],
                    "create_at": f.string(from: Date()),
                    "image_url" : metaData?.name,
                    "media_type" : "image",
                ] as [String : Any]
                addMessageToFirestore(docData)
            }
        })

        picker.dismiss(animated: true, completion: nil)
    }

    // 画像を指定された比率に縮小
    func resizeImage(image: UIImage, ratio: CGFloat) -> UIImage {
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x:0, y:0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    func addMessage(_ last_message: String) {
        let chat_message = last_message != "" ? last_message : "画像が送信されました。"
        presenter.apiChat(self.use_point, chat_message, message_users["room_code"]!)
    }
}

class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}


extension ChatMessageViewController: ChatMessageOutput {
    func update() {}
    func error() {}
}
