//
//  CustomTabBar.swift
//  matchness
//
//  Created by 中村篤史 on 2019/12/15.
//  Copyright © 2019 a2c. All rights reserved.
//

import UIKit
class CustomTabBar: UITabBar {

    let userDefaults = UserDefaults.standard
    var height_bar:Int = 0
    var device = 1

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        switch (UIScreen.main.nativeBounds.height) {
        case 480:
            // iPhone,3G,3GS
            height_bar = 100
//            print("heigh_1")
            break
        case 960:
            // iPhone 4,4S
//            print("heigh_2")
            break
        case 1136:
            // iPhone 5,5s,5c,SE
//            print("heigh_3")
            height_bar = 50
            break
        case 1334:
            // iPhone 6,6s,7,8
//            print("heigh_4")
            height_bar = 60
            break
        case 1792:
            //iPhone XR
//            print("heigh_7_1")
            height_bar = 85
            self.device = 2
            break
        case 1920:
//            print("heigh_4")
            height_bar = 60
            break
        case 2208:
            // iPhone 6 Plus,6s Plus,7 Plus,8 Plus
//            print("heigh_5")
            height_bar = 60
            self.device = 1
            break
        case 2436:
            //iPhone X
//            print("heigh_6")
            height_bar = 90
            self.device = 2
            break
        case 2688:
//            print("heigh_7")
            height_bar = 85
            self.device = 2
            break
        default:
//            print("heigh_8")
            height_bar = 85
            self.device = 2
            break
        }
//        print(UIScreen.main.nativeBounds.height)

        sizeThatFits.height = CGFloat(height_bar)
        return sizeThatFits;
    }
}
