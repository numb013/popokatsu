//
//  PointChangePresenter.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/15.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

protocol PointChangeInput {
    func apiPointSelect()
    func apiPointGet(_ type:Int, _ point:Int)
    var data: [ApiChangePoint] { get set }
}

protocol PointChangeOutput: AnyObject {
    func update()
    func error()
}

class PointChangePresenter: PointChangeInput {
    private weak var view: PointChangeOutput! // VCのこと
    var data = [ApiChangePoint]()
    var apiType = String()
    var isUpdate = false
    var page = Int()
    
    init(view: PointChangeOutput) {
        // このviewがVCのこと
        self.view = view
    }
    
    
    func apiPointSelect() {
        API.requestHttp(POPOAPI.base.pointSelect, parameters: nil,success: { [self] (response: [ApiChangePoint]) in
                data = response
                view.update()
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
    
    func apiPointGet(_ type: Int, _ point: Int) {
        let params = [
            "day_type": type,
            "change_point": point
        ] as [String: Any]

        API.requestHttp(POPOAPI.base.pointGet, parameters: params,success: { [self] (response: ApiStatus) in
                view.update()
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
}
