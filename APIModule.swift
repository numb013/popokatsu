//
//  APIModule.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation
import Alamofire

// Protocols
protocol APIModule {
    var platform: Platform { get }
    var endpoint: String { get }
}

extension APIModule {
    var url: String {
        return "\(platform.host)\(endpoint)"
    }
}


// Platform
enum Platform {
    case popo
    
    var host: String {
//        return "https://popokatsu.com/api"
//        return "https://ba46-133-32-128-167.ngrok.io/api"
        
        print("ホストAPIURL", Bundle.main.object(forInfoDictionaryKey: "api_url") as! String)
        return Bundle.main.object(forInfoDictionaryKey: "api_url") as! String
    }
}


// API Module
class POPOAPI {
    enum base: APIModule {
        case baseGet
        case foot
        case like
        case myFoot
        case myLike
        case myList
        case pointSelect
        case pointGet
        case userUpdate
        case usergGet
        case pointRank
        case pointHistory
        case pointPayment
        case pointComp
        case notice
        case menuSelect
        case menuEdit
        case userDelete
        case chatSend
        case noSNSAdd
        case profileEdit
        case userSearch
        case userPickUp
        case createSwipeLike
        case deleteFavoriteBlock
        case createFavoriteBlock
        case userDetail
        case userMe
        case selectMessage
        case selectMatche
        case selectMyTweet
        case likeTweet
        case likeCancelTweet
        case deleteTweet
        case deleteTweetComment
        case selectTweet
        case detailTweetComment
        case likeTweetList
        case createTweet
        case createTweetComment
        case selectWeekRank
        case selectWish
        case setWish
        case requestWish
        case rankUp
        case userAdd
        case createGroupCall
        case createGroupChat
        case createGroup
        case selectJoinAndEndGroup
        case selectRequestGroupEvent
        case requestGroupEvent
        case groupEventStart
        case recruitmentDeleteGroup
        case createReport
        case createContact
        case selectGroupEvent
        case selectTweetDetail
        case selectGroupChat
        case searchGroup
        case createLike
        case createRouletteHit
        case usedPoint
        
        var platform: Platform {
            return Platform.popo
        }
        var endpoint: String {
            switch self {
                case .baseGet: return "/base_param"
                case .foot: return "/footprint/user_footprint"
                case .like: return "/like/select_get_like"
                case .myFoot: return "/footprint/my_footprint"
                case .myLike: return "/like/select_get_my_like"
                case .myList: return "/select_FavoriteBlock"
                case .pointGet: return "/create_point"
                case .pointSelect: return "/select_point"
                case .usergGet: return "/user/user_info"
                case .userUpdate: return "/user/profile_update"
                case .pointRank: return "/point_change_rank"
                case .pointHistory: return "/select_point_purchase"
                case .pointPayment: return "/select_point_payment"
                case .pointComp: return "/pay_comp"
                case .notice: return "/select_Notice"
                case .menuSelect: return "/select_setting"
                case .menuEdit: return "/edit_setting"
                case .userDelete: return "/user/user_delete"
                case .chatSend: return "/send_message"
                case .noSNSAdd: return "/user/no_sns_add"
                case .profileEdit: return "/user/profile_edit"
                case .userSearch: return "/user/search"
                case .userPickUp: return "/user/pick_up"
                case .createSwipeLike: return "/create_swipe_like"
                case .deleteFavoriteBlock: return "/delete_FavoriteBlock"
                case .createFavoriteBlock: return "/create_FavoriteBlock"
                case .userDetail: return "/user/detail"
                case .userMe: return "/user/me"
                case .selectMessage: return "/select_message"
                case .selectMatche: return "/select_matche"
                case .selectMyTweet: return "/select_my_tweet"
                case .likeTweet: return "/like_tweet"
                case .likeCancelTweet: return "/like_cancel_tweet";
                case .deleteTweet: return "/delete_tweet";
                case .deleteTweetComment: return "/delete_tweet_comment"
                case .selectTweet: return "/select_tweet"
                case .detailTweetComment: return "/detail_tweet_comment"
                case .likeTweetList: return "/like_tweet_list"
                case .createTweet: return "/create_tweet"
                case .createTweetComment: return "/create_tweet_comment"
                case .selectWeekRank: return "/select_week_rank"
                case .selectWish: return "/select_wish"
                case .setWish: return "/set_wish"
                case .requestWish: return "/request_wish"
                case .rankUp: return "/rank_up"
                case .userAdd: return "/user/add"
                case .createGroupCall: return "/create_group_call"
                case .createGroupChat: return "/create_group_chat"
                case .createGroup: return "/create_group"
                case .selectJoinAndEndGroup: return "/select_join_and_end_group"
                case .selectRequestGroupEvent: return "/select_request_group_event"
                case .requestGroupEvent: return "/request_group_event"
                case .groupEventStart: return "/group_event_start"
                case .recruitmentDeleteGroup: return "/recruitment_delete_group"
                case .createReport: return "/create_report"
                case .createContact: return "/create_contact"
                case .selectGroupEvent: return "/select_group_event"
                case .selectTweetDetail: return "/select_tweet_detail"
                case .selectGroupChat: return "/select_group_chat"
                case .searchGroup: return "/search_group"
                case .createLike: return "/like/create_like"
                case .createRouletteHit: return "/create_roulette_hit"
                case .usedPoint: return "/user/used_point"
            }
        }
    }
    
//    enum multiple: APIModule {
//        case foot
//        case like
//        case myfoot
//        case mylike
//        case mylist
//
//        var platform: Platform {
//            return Platform.popo
//        }
//        var endpoint: String {
//            switch self {
//            case .foot: return "/footprint/user_footprint"
//            case .like: return "/like/select_get_like"
//            case .myfoot: return "/footprint/my_footprint"
//            case .mylike: return "/like/select_get_my_like"
//            case .mylist: return "/select_FavoriteBlock"
//            }
//        }
//    }
//
    
//    enum userInfo: APIModule {
//        case userget
//        case userselect
//
//        var platform: Platform {
//            return Platform.popo
//        }
//
//        var endpoint: String {
//            switch self {
//            case .userget: return "/create_point"
//            case .select: return "/select_point"
//            }
//        }
//    }
    
//    enum pointChange: APIModule {
//        case pointget
//        case pointupdate
//        case rank
//        case history
//
//        var platform: Platform {
//            return Platform.popo
//        }
//
//        var endpoint: String {
//            switch self {
//            case .pointget: return "/user/user_info"
//            case .pointupdate: return "/user/profile_update"
//            case .rank: return "/point_change_rank"
//            case .history: return "/select_point_purchase"
//            }
//        }
//    }

//    enum pointPayment: APIModule {
//        case payment
//        case pointcomp
//        var platform: Platform {
//            return Platform.popo
//        }
//
//        var endpoint: String {
//            switch self {
//            case .payment: return "/select_point_payment"
//            case .pointcomp: return "/pay_comp"
//            }
//        }
//    }
    
//    enum notice: APIModule {
//        case notice
//
//        var platform: Platform {
//            return Platform.popo
//        }
//
//        var endpoint: String {
//            switch self {
//            case .notice: return "/select_Notice"
//            }
//        }
//    }
    
//    enum menu: APIModule {
//        case menuselect
//        case menuedit
//        case userdelete
//
//        var platform: Platform {
//            return Platform.popo
//        }
//
//        var endpoint: String {
//            switch self {
//            case .menuselect: return "/select_setting"
//            case .menuedit: return "/edit_setting"
//            case .userdelete: return "/user/user_delete"
//
//            }
//        }
//    }
    
//    enum chat: APIModule {
//        case chatsend
//
//        var platform: Platform {
//            return Platform.popo
//        }
//
//        var endpoint: String {
//            switch self {
//            case .chatsend: return "/send_message"
//            }
//        }
//    }
//
//    enum SNS: APIModule {
//        case post
//        case comment
//        case reply
//        case edit
//        case delete
//        case sns
//        case like
//        case likecancel
//        case block
//        case detail
//        case commentDetail
//
//        var endpoint: String {
//            switch self {
//            case .post: return "/sns/post"
//            case .comment: return "/sns/comment"
//            case .reply: return "/sns/reply"
//            case .edit: return "/sns/edit"
//            case .delete: return "/sns/delete"
//            case .sns: return "/sns"
//            case .like: return "/sns/like"
//            case .likecancel: return "/sns/likecancel"
//            case .block: return "/sns/block"
//            case .detail: return "/sns/detail"
//            case .commentDetail: return "/sns/detail/comment"
//            }
//        }
//
//    }
    
}
