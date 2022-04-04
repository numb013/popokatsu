//
//  MultiplePresenter.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

protocol MultipleInput {
    func apiMultiple(_ page:Int, _ setData:APIModule)
    func apiMylist(_ page:Int, _ status:Int)
    var data: [ApiMultipleUser] { get set }
}

protocol MultipleOutput: AnyObject {
    func update(page:Int, isUpdate:Bool)
    func error()
}

class MultiplePresenter: MultipleInput {
    private weak var view: MultipleOutput! // VCのこと
    var data = [ApiMultipleUser]()
    var apiType = String()
    var isUpdate = false
    var page = Int()
    
    init(view: MultipleOutput) {
        // このviewがVCのこと
        self.view = view
    }
    
    func apiMultiple(_ page: Int, _ setData: APIModule) {
        API.requestHttp(setData, parameters: nil,success: { [self] (response: [ApiMultipleUser]) in
                data.append(contentsOf: response)
                isUpdate = data.count < 5 ? false : true
                view.update(page: self.page, isUpdate:isUpdate)
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
    
    func apiMylist(_ page:Int, _ status:Int) {
        let params = [
            "page": page,
            "status": status
        ] as [String: Any]

        API.requestHttp(POPOAPI.base.myList, parameters: params,success: { [self] (response: [ApiMultipleUser]) in
                data.append(contentsOf: response)
                isUpdate = data.count < 5 ? false : true
                view.update(page: self.page, isUpdate:isUpdate)
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
}
