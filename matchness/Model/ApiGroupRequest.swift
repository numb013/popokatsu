//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiGroupRequest: Codable {
    var group_id: Int?
    var event_peple: Int?
    var event_title: String?
    var decision_type: Int?
    var request_list: [ApiGroupRequestList]?
}
