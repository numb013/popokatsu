//
//  UINavigationController+.swift
//  matchness
//
//  Created by 中村篤史 on 2022/06/08.
//  Copyright © 2022 a2c. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    @objc func appearance() {
        let navigationBar = navigationController?.navigationBar
//        navigationBar?.setBackgroundImage(UIImage(), for: .default)
//        navigationBar?.isTranslucent = true
                                          
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        navigationBar?.scrollEdgeAppearance = appearance
        navigationBar?.standardAppearance = appearance
    }
    
}



