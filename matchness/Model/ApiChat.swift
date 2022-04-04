//
//  ApiChat.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

class ApiChat: Decodable {
    let userId: String?
    let userName: String?
    let userImage: String?
    let isArtist: Bool?
}
