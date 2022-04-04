
//  ApiMessageList.swift
//  map-menu02
//
//  Created by k1e091 on 2018/11/14.
//  Copyright © 2018 nakajima. All rights reserved.
//

import Foundation

class ApiMessageList:Codable {
    var target_name: String?
    var room_code: String?
    var last_message: String?
    var updated_at: String?
    var created_at: String?
    var target_id: String?
    var confirmed: Int?
    var profile_image: String?
}

