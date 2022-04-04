
//  ApiMessageList.swift
//  map-menu02
//
//  Created by k1e091 on 2018/11/14.
//  Copyright © 2018 nakajima. All rights reserved.
//

import Foundation

class ApiMessage: Codable {
    var id: Int?
    var name: String?
    var point: Int?
    var sex: Int?
    var profile_image: String?
    var message: [ApiMessageList]
}

