//
//  ChatMessagePresenter.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation

protocol ChatMessageInput {
    func apiChat(_ point:Int, _ message:String, _ room_code: String)
}

protocol ChatMessageOutput: AnyObject {
    func update()
    func error()
}

class ChatMessagePresenter: ChatMessageInput {
    private weak var view: ChatMessageOutput! // VCのこと
    init(view: ChatMessageOutput) {
        // このviewがVCのこと
        self.view = view
    }
    
    func apiChat(_ point:Int, _ last_message:String, _ room_code: String) {
        let params = [
            "point": String(point),
            "last_message":last_message,
            "room_code":room_code
        ] as [String: Any]
        API.requestHttp(POPOAPI.base.chatSend, parameters: params,success: { [self] (response: ApiStatus) in
            print("結果", response.status)
            },
            failure: { [self] error in
                print(error)
                view.error()
            }
        )
    }
}
