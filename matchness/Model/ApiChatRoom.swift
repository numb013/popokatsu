//
//  ApiChatRoomData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation;

class ApiChatRoom: Codable {
    var room_code: String?
    var user_hash_id: String?
    var target_hash_id: String?
    var last_message: String?
}
