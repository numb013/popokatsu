//
//  TutorialViewController.swift
//  matchness
//
//  Created by 中村篤史 on 2019/11/12.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @objc func buttonTapped(sender : AnyObject) {
        let storyboard: UIStoryboard = self.storyboard!
        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
        let multiple = storyboard.instantiateViewController(withIdentifier: "start")
        multiple.modalPresentationStyle = .fullScreen
        //ここが実際に移動するコードとなります
        self.present(multiple, animated: true, completion: nil)
     }
    
    
    @IBAction func toTop(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
        let multiple = storyboard.instantiateViewController(withIdentifier: "userSearch") as? UserSearchViewController
        multiple!.modalPresentationStyle = .fullScreen
        //ここが実際に移動するコードとなります
        self.present(multiple!, animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
