//
//  ApiUserSearchData.swift
//  matchness
//
//  Created by RW on 2019/07/10.
//  Copyright © 2019 a2c. All rights reserved.
//

import Foundation

class ApiUserSearchData:Codable {
    var page_no: Int?
    var user_list: [ApiUserDate]
}
