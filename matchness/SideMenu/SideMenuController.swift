//
//  SideMenuController.swift
//  matchness
//
//  Created by 中村篤史 on 2021/10/01.
//  Copyright © 2021 a2c. All rights reserved.
//

import UIKit

class SideMenuController: UITableViewController, UIViewControllerTransitioningDelegate, SideMenuProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SideProfileCell", bundle: nil), forCellReuseIdentifier: "SideProfileCell")
        self.tableView.register(UINib(nibName: "StepSideCell", bundle: nil), forCellReuseIdentifier: "StepSideCell")
        self.tableView.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        self.tableView.register(UINib(nibName: "SideMenuCollectionCell", bundle: nil), forCellReuseIdentifier: "SideMenuCollectionCell")
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
    }
    
    // 追加
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = true
    }
    // 追加
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.isNavigationBarHidden = false
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as! SideMenuCell
            cell.icon.isUserInteractionEnabled = true
            var recognizer = MyTapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            cell.icon.addGestureRecognizer(recognizer)
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepSideCell") as! StepSideCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCollectionCell") as! SideMenuCollectionCell
        cell.width = view.frame.width
        cell.delegate = self
        return cell
    }

    @objc func onTap(_ sender: MyTapGestureRecognizer) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()! as! ProfileEditViewController
        vc.modalPresentationStyle = .popover
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func selected(_ vc: UIViewController, _ type:pageType) {
        switch type {
            case .present:
                vc.modalPresentationStyle = .popover
                vc.transitioningDelegate = self
                present(vc, animated: true, completion: nil)
            case .naviFull:
                vc.modalPresentationStyle = .fullScreen
                vc.transitioningDelegate = self
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.backgroundColor = .black
                navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                self.present(navigationController, animated: true, completion: nil)
            default:
                navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 97
        }
        if indexPath.row == 2 {
            return 450
        }
        tableView.estimatedRowHeight
        return UITableView.automaticDimension
    }
}
