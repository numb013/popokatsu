//
//  ApiFavoriteBlock.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/19.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

class ApiFavoriteBlock:Codable {
    var user_id: Int
    var target_id: Int?
    var deleted_at: String?
    var status: Int?
    var updated_at: String?
    var created_at: String?
    var id: Int
}


