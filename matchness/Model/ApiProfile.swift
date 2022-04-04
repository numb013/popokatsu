//
//  ApiProfile.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/21.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation


class ApiProfile: Codable {
    var age:Int?
    var birthday:String?
    var blood_type:Int?
    var fitness_parts_id:Int?
    var id:Int?
    var name:String?
    var point:Int?
    var prefecture_id:Int?
    var profile_text:String?
    var rank:Int?
    var sex:Int?
    var status:Int?
    var weight:Int?
    var work:Int?
    var profile_image:[ApiProfileImage]
}
