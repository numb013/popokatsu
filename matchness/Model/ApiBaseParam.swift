//
//  BaseParam.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

class ApiBaseParam: Codable {
    let point: Int
    var notice: Int
    let tweet: Int
    var like: Int
    let rank: Int
    let message: Int
    let match: Int?
    var footprint: Int
    let status: Int
    let join_group: Int
    let api_token: String
    let profile_image: String
    let user_name: String
}
