//
//  ApiDataShop.swift
//  Alamofire01
//
//  Created by k1e091 on 2017/08/16.
//  Copyright © 2017年 k-1.ne.jp. All rights reserved.
//

import Foundation;

class ApiChangePoint: Codable {
    var user_id: Int?
    var point: Int?
    var todayPointChenge: Int?
    var yesterdayPointChenge: Int?
    var dayAfterTomorrowPointChenge: Int?
}
