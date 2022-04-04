//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//
import Foundation;

class ApiTweetList: Codable {
    var tweet_id: Int
    var user_id: Int
    var type: Int
    var like_count:Int
    var message: String
    var created_at: String
    var comment_count: Int
    var name: String
    var prefecture_id: Int
    var profile_image: String
    var is_like: Int
    var my_tweet: Int
    var my_tweet_comment: Int?
    var tweet_comment_id: Int?
    var target_name: String?
}
