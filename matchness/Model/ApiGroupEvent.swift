//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiGroupEvent: Codable {
    var chat_confirm: Int?
    var event_peple: String?
    var event_time: String?
    var event_title: String?
    var rank: Int?
    var status: Int?
    var step: Int?
    var user_id: Int?
    var group_event: [ApiGroupEventList]
}

//chat_confirm: Int?
//event_peple: String?
//event_time: String?
//event_title: String?
//rank:Int?
//status:Int?
//step:Int?
//user_id: Int?
