//
//  ApiChatRoomData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation;

class ApiWeekRanking: Codable {
    var rank: Int
    var step: Int
    var week_rank_list: [ApiWeekRankList]
}

class ApiWeekRankList: Codable {
    var user_id:Int
    var name:String
    var prefecture_id:Int
    var step:Int
    var profile_image:String
    var action_datetime:String
    var age:Int
    var my_rank:Int
}
