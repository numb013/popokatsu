//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiUserDetailDate: Codable {
    var id:Int?
    var name:String?
    var work:Int?
    var sex:Int?
    var rank:Int?
    var blood_type:Int?
    var point:Int?
    var birthday:String?
    var prefecture_id:Int?
    var profile_text:String?
    var fitness_parts_id:Int?
    var is_like:Int?
    var favorite_block_status:Int?
    var is_matche:Int?
    var age:Int?
    var room_code:String?
    var profile_image:[ApiProfileImage]
    var my_id:Int?
    var my_name:String?
    var my_point:Int?
    var my_sex:Int?
    var my_profile_image:String?
    var target_imag:String?
    var mypage_view:Int?
}


