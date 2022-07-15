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
import SDWebImage

//-------------------------------------------------------------------------------------------------------------------------------------------------
@available(iOS 13.0, *)
class AddTweetView: BaseViewController, UITextViewDelegate, UITextFieldDelegate {
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet var textViewPost: UITextView!
    private var requestAlamofire: Alamofire.Request?;
    @IBOutlet var textCountView: UIView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    
    var activityIndicatorView = UIActivityIndicatorView()
	private var placeholderLabel = UILabel()
    let image_url: String = ApiConfig.REQUEST_URL_IMEGE;
    var name = String()
    var message = String()
    var point = 0
    let tweet_place = ["今何してる？","今日はどれぐらい歩いた？", "健康法は？", "おすすめのダイエットは？", "休日の過ごし方は","運動で気を使っている事は？"]
    
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
//        loadData()
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.title = ""
        //タブバー非表示
        tabBarController?.tabBar.isHidden = true
        self.textViewPost.becomeFirstResponder()
        loadData()
    }

    func loadData() {
        tweetButton.layer.cornerRadius = tweetButton.frame.height / 2
        var profile_image = userDefaults.object(forKey: "profile_image") as? String
        let profileImageURL = image_url + (profile_image!)
        imageUser.sd_setImage(with: NSURL(string: profileImageURL)! as URL)

        self.point = self.userDefaults.object(forKey: "point") as! Int
        textCount.text = "0 / " + String(self.point)
        var number = Int.random(in: 0 ... 5)
		placeholderLabel.text = tweet_place[number]
		placeholderLabel.font = textViewPost.font
		placeholderLabel.sizeToFit()
		placeholderLabel.frame.origin = CGPoint(x: 5, y: textViewPost.font!.pointSize / 2)
		placeholderLabel.textColor = UIColor.quaternaryLabel
		placeholderLabel.isHidden = !textViewPost.text.isEmpty
		textViewPost.addSubview(placeholderLabel)
	}

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty

        let commentNum = textViewPost.text.count
        self.message = textViewPost.text!
        self.point = self.userDefaults.object(forKey: "point") as! Int
        textCount.text = String(commentNum) + " / " + String(self.point)

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

    func validator(_ status: Int){
        self.activityIndicatorView.stopAnimating()
        // アラート作成
        var alert = UIAlertController(title: "入力して下さい", message: "入力して下さい", preferredStyle: .alert)
        if status == 1 {
            alert = UIAlertController(title: "入力して下さい", message: "入力して下さい", preferredStyle: .alert)
        } else if status == 2 {
            let alertController:UIAlertController =
                UIAlertController(title:"文字数オーバー",message: "つぶやきは1ポイント１文字になります", preferredStyle: .alert)
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

        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }

    @IBAction func actionDone(_ sender: Any) {
        textViewPost.endEditing(true)
        self.point = self.userDefaults.object(forKey: "point") as! Int
        let parameters = [
            "type": "1",
            "message": self.message,
            "use_point": self.message.count
        ] as [String:Any]
        
        if (parameters["message"] as! String == "") {
            validator(1)
            return
        }
        if ((parameters["message"]! as! String).count > self.point) {
            validator(2)
            return
        }
        API.requestHttp(POPOAPI.base.createTweet, parameters: parameters,success: { [self] (response: detailParam) in
            if response.status == "NG" {
                if response.message == "2" {
                    let alertController:UIAlertController =
                        UIAlertController(title:"ポイントが不足しています",message: "いいねするにはポイント5p必要です", preferredStyle: .alert)
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
            let alert = UIAlertController(title: "つぶやき", message: "投稿しました。", preferredStyle: .alert)
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
