//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation;

class ApiUserDate:Codable {
    var id:Int
    var hash_id:String
    var name:String
    var sex:Int
    var rank:Int
    var point:Int
    var birthday:String
    var prefecture_id:Int
    var profile_text:String
    var created_at:String
    var profile_image:String
    var last_login_flag:Int?
    var created_flag:Int?
    var age:Int
}



