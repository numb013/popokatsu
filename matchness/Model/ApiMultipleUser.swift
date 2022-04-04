//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiMultipleUser: Codable {
    var id: Int?
    var name: String?
    var user_id: Int?
    var target_id: Int?
    var confirmed: Int?
    var prefecture_id: Int?
    var created_at: String?
    var updated_at: String?
    var profile_image: String?
}
