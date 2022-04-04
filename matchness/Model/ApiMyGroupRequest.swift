//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiMyGroupRequest: Codable {
    var id: Int?
    var master_id: Int?
    var title: String?
    var event_period: Int?
    var event_peple: Int?
    var status: Int?
    var present_point: Int?
}
