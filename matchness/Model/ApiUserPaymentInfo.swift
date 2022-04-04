//
//  ApiMatcheList.swift
//  map-menu02
//
//  Created by k1e091 on 2018/11/14.
//  Copyright © 2018 nakajima. All rights reserved.
//

import Foundation

class ApiUserPaymentInfo: Codable {
    var card_no: String?
    var card_company: String?
    var payment_point_list: [ApiPaymentPointList]
}
