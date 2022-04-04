//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiNoticeList:Codable {
    var notice_id: Int?
    var target_id: Int?
    var type: Int?
    var sub_type: Int?
    var title: String?
    var body_text: String?
    var confirmed: Int?
    var created_at: String?
}
