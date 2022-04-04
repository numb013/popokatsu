//
//  Message.swift
//  matchness
//
//  Created by 中村篤史 on 2021/11/22.
//  Copyright © 2021 a2c. All rights reserved.
//

import Foundation
import Firebase

class Message {
    let name: String
    let text:String
    let from: String
    let media_type: String
    let image_url:String?
    let create_at: String

    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.text = dic["text"] as? String ?? ""
        self.from = dic["from"] as? String ?? ""
        self.media_type = dic["media_type"] as? String ?? ""
        self.image_url = dic["image_url"] as? String ?? ""
        self.create_at = dic["create_at"] as? String ?? ""
    }
    
}



