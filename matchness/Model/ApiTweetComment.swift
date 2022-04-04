//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//
import Foundation

class ApiTweetComment: Codable {
    var user_id: Int?
    var tweet_comment_id: Int?
    var name: String?
    var target_name: String?
    var age: String?
    var profile_image: String?
    var like_count: Int?
    var message: String?
    var to_name: String?
    var created_at: String?
    var tweet_id: Int?
    var type: Int?
    var is_like: Int?
    var my_tweet: Int?
    var my_tweet_comment: Int?
    var comment_count: Int?
}
