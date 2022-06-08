//
// Copyright (c) 2020 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Alamofire
import SwiftyJSON

//-------------------------------------------------------------------------------------------------------------------------------------------------
@available(iOS 13.0, *)
class AddTweetCommentView: BaseViewController, UITextViewDelegate, UITextFieldDelegate {
    let userDefaults = UserDefaults.standard
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var textViewPost: UITextView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var target_name: UIButton!
    @IBOutlet weak var imageTopMargin: NSLayoutConstraint!
    @IBOutlet var textCountView: UIView!
    @IBOutlet weak var reNameTopMargin: NSLayoutConstraint!
    @IBOutlet weak var tweetButton: UIButton!
    
    private var requestAlamofire: Alamofire.Request?;
    var activityIndicatorView = UIActivityIndicatorView()
    private var placeholderLabel = UILabel()
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var name = String()
    var target_user_id = Int()
    var message = String()
    var tweet_id = Int()
    var point = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewPost.delegate = self
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        
        navigationController!.navigationBar.topItem!.title = ""
        navigationController?.setNavigationBarHidden(false, animated: false)

        textViewPost.inputAccessoryView = textCountView
        imageUser.layer.cornerRadius = imageUser.frame.width / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = ""
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        self.textViewPost.becomeFirstResponder()
        loadData()
    }
    
    // MARK: - Data methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadData() {

        //1:ノーマル 2:XR
        if UIScreen.main.nativeBounds.height >= 1792 {
            self.imageTopMargin.constant = 100
            self.reNameTopMargin.constant = 100
            self.view.layoutIfNeeded()
        } else {
            self.imageTopMargin.constant = 60
            self.reNameTopMargin.constant = 60
            self.view.layoutIfNeeded()
        }
        tweetButton.layer.cornerRadius = tweetButton.frame.height / 2

        var profile_image = userDefaults.object(forKey: "profile_image") as? String
        let profileImageURL = image_url + (profile_image!)
        imageUser.sd_setImage(with: NSURL(string: profileImageURL)! as URL)
        imageUser.layer.cornerRadius = imageUser.frame.size.width * 0.5
        
        self.point = self.userDefaults.object(forKey: "point") as! Int
        textCount.text = "0 / " + String(self.point)

        placeholderLabel.text = "今何してる？"
        placeholderLabel.font = textViewPost.font
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: textViewPost.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor.quaternaryLabel
        placeholderLabel.isHidden = !textViewPost.text.isEmpty
        textViewPost.addSubview(placeholderLabel)
        
        target_name.titleLabel?.adjustsFontSizeToFitWidth = true
        target_name.titleLabel?.minimumScaleFactor = 0.8
        target_name.setTitle(" Re:" + name + " ", for: .normal)
        target_name.backgroundColor = .popoTextGreen
        target_name.layer.cornerRadius = 13
        target_name.clipsToBounds = true
        self.point = self.userDefaults.object(forKey: "point") as! Int
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let commentNum = textViewPost.text.count
        self.message = textViewPost.text!
        self.point = self.userDefaults.object(forKey: "point") as! Int
        textCount.text = String(commentNum) + " / " + String(point)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.message = textField.text!
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        var tag = textField.tag
        self.message = textField.text!
        textField.resignFirstResponder()
        return
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    @objc func onClickCommitButton (sender: UIButton) {
        if(textViewPost.isFirstResponder){
            textViewPost.resignFirstResponder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.message = textField.text!
        textField.resignFirstResponder()
        return true
    }


    
    @objc func actionCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func validator(_ status:Int){
        self.activityIndicatorView.stopAnimating()
        // アラート作成
        var alert = UIAlertController(title: "入力して下さい", message: "入力して下さい", preferredStyle: .alert)
        if status == 1 {
            alert = UIAlertController(title: "入力して下さい", message: "入力して下さい", preferredStyle: .alert)
        } else if status == 2 {
            alert = UIAlertController(title: "文字数オーバー", message: "つぶやきは1ポイント１文字になります", preferredStyle: .alert)
        }
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    @IBAction func actionDone(_ sender: Any) {
        textViewPost.endEditing(true)

        let parameters = [
            "type": "1",
            "message": self.message,
            "tweet_id": self.tweet_id,
            "use_point": self.message.count,
            "target_user_id": self.target_user_id
        ] as [String:Any]
        
        if (parameters["message"] as! String == "") {
            validator(1)
            return
        }
        if ((parameters["message"]! as! String).count > self.point) {
            validator(2)
            return
        }
        
        API.requestHttp(POPOAPI.base.createTweetComment, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
                if response.message == "2" {
                    let alertController:UIAlertController =
                        UIAlertController(title:"ポイントが不足しています",message: "つぶやくにはポイント50p必要です", preferredStyle: .alert)
                    let backView = alertController.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 15.0
                    backView?.backgroundColor = .white
                    // Default のaction
                    let defaultAction:UIAlertAction =
                        UIAlertAction(title: "ポイント変換ページへ",style: .destructive,handler:{
                            (action:UIAlertAction!) -> Void in
                            let vc = UIStoryboard(name: "pointChange", bundle: nil).instantiateInitialViewController()! as! PointChangeViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        })

                    // Cancel のaction
                    let cancelAction:UIAlertAction =
                        UIAlertAction(title: "キャンセル",style: .cancel,handler:{
                            (action:UIAlertAction!) -> Void in
                            // 処理
                            print("キャンセル")
                        })
                    cancelAction.setValue(UIColor.popoTextGreen, forKey: "titleTextColor")
                    defaultAction.setValue(UIColor.popoTextPink, forKey: "titleTextColor")
                    // actionを追加
                    alertController.addAction(cancelAction)
                    alertController.addAction(defaultAction)
                    // UIAlertControllerの起動
                    self.present(alertController, animated: true, completion: nil)
                }

            }
            // アラート作成
            let alert = UIAlertController(title: "つぶやきコメント", message: "つぶやきにコメントしました。", preferredStyle: .alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 15.0
            backView?.backgroundColor = .white
            // アラート表示
            self.present(alert, animated: true, completion: {
                // アラートを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                })
            })
            },
            failure: { [self] error in
                print(error)
            }
        )
    }
}
