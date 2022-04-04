//
//  ApiMatcheList.swift
//  map-menu02
//
//  Created by k1e091 on 2018/11/14.
//  Copyright © 2018 nakajima. All rights reserved.
//

import Foundation

class ApiGroupCallList: Codable {
    var id: Int?
    var from_id: Int?
    var target_id: Int?
    var message: String?
    var name: String?
    var hash_id: String?
}
