//
//  ProfileEditPresenter.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

protocol ProfileEditInput {
    func apiUserInfo()
    func apiUpdate(_ query:[String:Any])
    var data: [ApiProfile] { get set }
}

protocol ProfileEditOutput: AnyObject {
    func update(_ type:String)
    func error()
}

class ProfileEditPresenter: ProfileEditInput {

    private weak var view: ProfileEditOutput! // VCのこと
    var data = [ApiProfile]()
    var apiType = String()
    var isUpdate = false
    var page = Int()
    
    init(view: ProfileEditOutput) {
        // このviewがVCのこと
        self.view = view
    }
    
    func apiUserInfo() {
        API.requestHttp(POPOAPI.base.usergGet, parameters: nil,success: { [self] (response: [ApiProfile]) in
                data = response
                view.update("get")
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
    
    func apiUpdate(_ query: [String : Any]) {
        API.requestHttp(POPOAPI.base.userUpdate, parameters: query,success: { [self] (response: [ApiProfile]) in
                data = response
                DispatchQueue.main.async {
                    view.update("update")
                }
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
}
