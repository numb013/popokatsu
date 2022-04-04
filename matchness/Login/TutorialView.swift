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

//-------------------------------------------------------------------------------------------------------------------------------------------------
class TutorialView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet var pageControl: UIPageControl!
	private var collections: [[String: String]] = []
    let userDefaults = UserDefaults.standard
    let button = UIButton()
    @IBOutlet weak var skipbutton: UIButton!
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: pageControl)
        collectionView.register(UINib(nibName: "TutorialCell", bundle: nil), forCellWithReuseIdentifier: "TutorialCell")
        pageControl.pageIndicatorTintColor = UIColor.lightGray

        //タブバー非表示
        tabBarController?.tabBar.isHidden = true

        loadCollections()
    }

    @objc func goStart(_ sender : Any) {
        self.userDefaults.set("1", forKey: "login_step_1")
        dismiss(animated: true)
    }
    
	// MARK: - Collections methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadCollections() {

		collections.removeAll()

        var dict1: [String: String] = [:]
        var dict2: [String: String] = [:]
        var dict3: [String: String] = [:]
        var dict4: [String: String] = [:]

        dict1["title"] = "歩いた歩数をポイントに交換しよう"
        dict1["description"] = "100歩で1ポイント交換できる"
        collections.append(dict1)
        
        dict2["title"] = "好みのパートナーを見つけよう"
		dict2["description"] = "いいねしてマッチングしたらメッセージを送ろう"
		collections.append(dict2)
        
        dict3["title"] = "マイデータで毎日の歩数を管理"
        dict3["description"] = "いいねしてマッチングしたらメッセージを送ろう"
        collections.append(dict3)
        
        dict4["title"] = "ウォーキングライフをつぶやいてみよう"
        dict4["description"] = "つぶやきは1ポイントで１文字つぶやけます"
		collections.append(dict4)


        


//		refreshCollectionView()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------

    @objc func actionSkip() {
        dismiss(animated: true)
    }
    
    
    @IBAction func skipButton(_ sender: Any) {
        self.userDefaults.set("1", forKey: "login_step_1")
        dismiss(animated: true)
    }
    
    
    
	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshCollectionView() {

//		collectionView.reloadData()
	}
}

// MARK:- UICollectionViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension TutorialView: UICollectionViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return collections.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCell", for: indexPath) as! TutorialCell
        
        cell.imageView.image = UIImage(named: "1tuto")
        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "tuto1")
        }
        if indexPath.row == 1 {
            cell.imageView.image = UIImage(named: "tuto2")
        }
        if indexPath.row == 2 {
            cell.imageView.image = UIImage(named: "tuto3")
        }
        if indexPath.row == 3 {
            cell.imageView.image = UIImage(named: "tuto4")
        }
//
		cell.bindData(index: indexPath.item, data: collections[indexPath.row])
		return cell
	}
}

// MARK:- UICollectionViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension TutorialView: UICollectionViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		print("didSelectItemAt \(indexPath.row)")
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            self.skipbutton.setTitle("閉じる", for: .normal)
        } else {
            self.skipbutton.setTitle("skip", for: .normal)
        }
		pageControl.currentPage = indexPath.row
	}
}

// MARK:- UICollectionViewDelegateFlowLayout
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension TutorialView: UICollectionViewDelegateFlowLayout {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		let height = collectionView.frame.size.height
		let width = collectionView.frame.size.width

		return CGSize(width: width, height: height)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

		return 0
	}
}
