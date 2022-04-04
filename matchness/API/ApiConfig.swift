//
//  AIConfig.swift
//  Aniimg
//
//  Created by k1e091 on 2017/12/07.
//  Copyright © 2017年 aniimg. All rights reserved.
//
/*
 
 */
public struct ApiConfig {
    static var FIREBASE_CLIENTID: String = "806178990139-ei082f93503lki48k1us1i88rk9pu6bb.apps.googleusercontent.com";

    static var SITE_DOMAIN: String = "popokatsu.com";
    static let SITE_BASE_URL: String = "https://" + SITE_DOMAIN;
//    static let REQUEST_URL_API: String = SITE_BASE_URL + "/api";

    static let ADUNIT_ID: String = "ca-app-pub-3233612928012980/4745767555"//本番
//    static let ADUNIT_ID: String = "ca-app-pub-3940256099942544/2934735716"//テスト
    static let REQUEST_URL_IMEGE: String = "https://storage.googleapis.com/popokatsu-content/"

    static let BANER_HEIGHT: Int = 45
    

    
//    //ユーザー一覧
//    static let REQUEST_URL_API_USER_SEARCH: String = REQUEST_URL_API + "/user/search";
//    //ユーザー詳細
//    static let REQUEST_URL_API_USER_DETAIL: String = REQUEST_URL_API + "/user/detail";
//    //プロフィール取得
//    static let REQUEST_URL_API_USER_INFO: String = REQUEST_URL_API + "/user/user_info";
//
//    static let REQUEST_URL_API_MY_PAGE: String = REQUEST_URL_API + "/user/my_page";
//
//    //ユーザー作成
//    static let REQUEST_URL_API_USER_ADD: String = REQUEST_URL_API + "/user/add";
//    static let REQUEST_URL_API_NO_SNS_USER_ADD: String = REQUEST_URL_API + "/user/no_sns_add";
//
//    //プロフィール編集
//    static let REQUEST_URL_API_USER_PROFILE_EDIT: String = REQUEST_URL_API + "/user/profile_edit";
//    //プロフィール編集
//    static let REQUEST_URL_API_USER_PROFILE_UPDATE: String = REQUEST_URL_API + "/user/profile_update";
//
//    //マイデータ
//    static let REQUEST_URL_API_ME: String = REQUEST_URL_API + "/user/me";
////
////    static let REQUEST_URL_API_USER_INFO: String = REQUEST_URL_API + "/user/user_info";
//
//    static let REQUEST_URL_API_POINT_UPDATE: String = REQUEST_URL_API + "/user/point_update";
//    static let REQUEST_URL_API_USER_DELETE: String = REQUEST_URL_API + "/user/user_delete";
//    //足跡
//    static let REQUEST_URL_API_USER_FOOTPRINT: String = REQUEST_URL_API + "/footprint/user_footprint";
//    //自分の足跡
//    static let REQUEST_URL_API_MY_FOOTPRINT: String = REQUEST_URL_API + "/footprint/my_footprint";
//    //いいね
//    static let REQUEST_URL_API_ADD_LIKE: String = REQUEST_URL_API + "/like/create_like";
//    //もらったいいね
//    static let REQUEST_URL_API_SEECT_GET_LIKE: String = REQUEST_URL_API + "/like/select_get_like";
//    //自分からいいね
//    static let REQUEST_URL_API_SEECT_GET_MY_LIKE: String = REQUEST_URL_API + "/like/select_get_my_like";
//    //グループ取得
//    static let REQUEST_URL_API_SELECT_GROUP: String = REQUEST_URL_API + "/select_group";
//    static let REQUEST_URL_API_ADD_GROUP: String = REQUEST_URL_API + "/create_group";
//    static let REQUEST_URL_API_SELECT_JOIN_AND_END_GROUP: String = REQUEST_URL_API + "/select_join_and_end_group";
//    static let REQUEST_URL_API_SELECT_GROUP_EVENT: String = REQUEST_URL_API + "/select_group_event";
//    static let REQUEST_URL_API_SELECT_REQUEST_GROUP_EVENT: String = REQUEST_URL_API + "/select_request_group_event";
//    static let REQUEST_URL_API_REQUEST_GROUP_EVENT: String = REQUEST_URL_API + "/request_group_event";
//    static let REQUEST_URL_API_RECRUITMENT_DELETE_GROUP: String = REQUEST_URL_API + "/recruitment_delete_group";
//    static let REQUEST_URL_API_DELETE_POINT: String = REQUEST_URL_API + "/delete_point";
//    static let REQUEST_URL_API_UPDATE_POINT: String = REQUEST_URL_API + "/update_point";
//    static let REQUEST_URL_API_ADD_POINT: String = REQUEST_URL_API + "/create_point";
//    static let REQUEST_URL_API_SELECT_POINT: String = REQUEST_URL_API + "/select_point";
//    static let REQUEST_URL_API_ADD_MATCHE: String = REQUEST_URL_API + "/create_matche";
//    static let REQUEST_URL_API_SELECT_MATCHE: String = REQUEST_URL_API + "/select_matche";
//    static let REQUEST_URL_API_ADD_MESSAGE: String = REQUEST_URL_API + "/create_message";
//    static let REQUEST_URL_API_SELECT_MESSAGE: String = REQUEST_URL_API + "/select_message";
//    static let REQUEST_URL_API_SEND_MESSAGE: String = REQUEST_URL_API + "/send_message";
//    static let REQUEST_URL_API_ADD_GROUP_CHAT: String = REQUEST_URL_API + "/create_group_chat";
//    static let REQUEST_URL_API_SELECT_GROUP_CHAT: String = REQUEST_URL_API + "/select_group_chat";
//    static let REQUEST_URL_API_SEARCH_GROUP: String = REQUEST_URL_API + "/search_group";
//    static let REQUEST_URL_API_SELECT_NOTICE: String = REQUEST_URL_API + "/select_Notice";
//    static let REQUEST_URL_API_SELECT_NOTICE_TEXT_BODY: String = REQUEST_URL_API + "/select_Notice_text_body";
//    static let REQUEST_URL_API_ADD_FAVORITE_BLOCK: String = REQUEST_URL_API + "/create_FavoriteBlock";
//    static let REQUEST_URL_API_DELETE_FAVORITE_BLOCK: String = REQUEST_URL_API + "/delete_FavoriteBlock";
//    static let REQUEST_URL_API_SELECT_FAVORITE_BLOCK: String = REQUEST_URL_API + "/select_FavoriteBlock";
//    static let REQUEST_URL_API_ADD_REPORT: String = REQUEST_URL_API + "/create_report";
//    static let REQUEST_URL_API_ADD_CONTACT: String = REQUEST_URL_API + "/create_contact";
//    static let REQUEST_URL_API_EDIT_SETTING: String = REQUEST_URL_API + "/edit_setting";
//    static let REQUEST_URL_API_SELECT_SETTING: String = REQUEST_URL_API + "/select_setting";
//    static let REQUEST_URL_API_SELECT_POINT_PAYMENT: String = REQUEST_URL_API + "/select_point_payment";
//    static let REQUEST_URL_API_CHARGE: String = REQUEST_URL_API + "/charge";
//    static let REQUEST_URL_API_REGISTRATION_CREDIT: String = REQUEST_URL_API + "/registration-credit";
//    static let REQUEST_URL_API_SELECT_PAYMENT_EDIT_LIST: String = REQUEST_URL_API + "/select_payment_edit_list"
//    static let REQUEST_URL_API_SELECT_POINT_PURCHASE: String = REQUEST_URL_API + "/select_point_purchase";
//    static let REQUEST_URL_API_POINT_CHECK: String = REQUEST_URL_API + "/point_check";
////    static let REQUEST_URL_API_BASE_PARAM: String = REQUEST_URL_API + "/base_param";
//    static let REQUEST_URL_API_GROUP_EVENT_START: String = REQUEST_URL_API + "/group_event_start";
//    static let REQUEST_URL_API_RANK_UP: String = REQUEST_URL_API + "/rank_up";
//    static let REQUEST_URL_API_SELECT_WISH: String = REQUEST_URL_API + "/select_wish";
//    static let REQUEST_URL_API_SET_WISH: String = REQUEST_URL_API + "/set_wish";
//    static let REQUEST_URL_API_REQUEST_WISH: String = REQUEST_URL_API + "/request_wish";
//    static let REQUEST_URL_API_PAY_COMP: String = REQUEST_URL_API + "/pay_comp";
//    static let REQUEST_URL_API_POINT_CHANGE_RANK: String = REQUEST_URL_API + "/point_change_rank";
//    static let REQUEST_URL_API_USER_PIKUP: String = REQUEST_URL_API + "/user/pick_up";
//    static let REQUEST_URL_API_ADD_GROUP_CALL: String = REQUEST_URL_API + "/create_group_call";
//    static let REQUEST_URL_API_GROUP_CALL: String = REQUEST_URL_API + "/select_group_call";
//    static let REQUEST_URL_API_REQUEST_GROUP_CALL: String = REQUEST_URL_API + "/request_group_call";
//    static let REQUEST_URL_API_SWIPE_LIKE: String = REQUEST_URL_API + "/create_swipe_like";
//    //つぶやき
//    static let REQUEST_URL_API_ADD_TWEET: String = REQUEST_URL_API + "/create_tweet";
//    static let REQUEST_URL_API_DETAIL_TWEET: String = REQUEST_URL_API + "/select_tweet_detail";
//    static let REQUEST_URL_API_DETAILE_TWEET_COMMENT: String = REQUEST_URL_API + "/detail_tweet_comment";
//    static let REQUEST_URL_API_DELETE_TWEET: String = REQUEST_URL_API + "/delete_tweet";
//    static let REQUEST_URL_API_DELETE_TWEET_COMMENT: String = REQUEST_URL_API + "/delete_tweet_comment";
//    static let REQUEST_URL_API_SELECT_TWEET: String = REQUEST_URL_API + "/select_tweet";
//    static let REQUEST_URL_API_SELECT_MY_TWEET: String = REQUEST_URL_API + "/select_my_tweet";
//    static let REQUEST_URL_API_ADD_TWEET_COMMENT: String = REQUEST_URL_API + "/create_tweet_comment";
//    static let REQUEST_URL_API_LIKE_TWEET: String = REQUEST_URL_API + "/like_tweet";
//    static let REQUEST_URL_API_LIKE_CANCEL_TWEET: String = REQUEST_URL_API + "/like_cancel_tweet";
//    static let REQUEST_URL_API_LIKE_TWEET_LIST: String = REQUEST_URL_API + "/like_tweet_list";
//    //新グループ
//    static let REQUEST_URL_API_NEW_GROUP_PEPLE: String = REQUEST_URL_API + "/new_group_peple";
//    static let REQUEST_URL_API_SELECT_WEEK_RANK: String = REQUEST_URL_API + "/select_week_rank"
    
    
    static let WORK_LIST: [String] = ["未選択", "クリエイティブ", "コンピューター","出版", "放送", "流通", "金融", "医療・福祉", "教育・語学", "国家・自治体", "旅行関係", "料理関係", "動物・自然", "オフィス", "サービス", "エンターテイメント", "美容・ファッション", "建築・インテリア", "モノづくり", "交通機関", "冠婚葬祭", "自由業", "学生"]

    static let PREFECTURE_LIST: [String] = ["未選択", "北海道","青森","岩手","秋田","宮城","山形","福島","新潟","茨城","栃木","群馬","埼玉","千葉","東京","神奈川","長野","山梨","静岡","岐阜","愛知","富山","石川","福井","滋賀","三重","京都","奈良","和歌山","大阪","兵庫","岡山","鳥取","島根","広島","山口","香川","愛媛","徳島","高知","福岡","佐賀","大分","長崎","熊本","宮崎","鹿児島","沖縄","海外"]
    static let FITNESS_LIST: [String] = ["未選択", "顔・フェイス","あご・首","胸・バスト","手首・足首","腕・二の腕","お腹・下腹","お尻・ヒップ","肩・背中","太もも・脹脛"]

    static let SEX_LIST: [String] = ["未選択", "女性", "男性"]
    static let BLOOD_LIST: [String] = ["未選択", "A型","B型","O型","AB型"]
    static let EVENT_START_TYPE: [String] = ["未選択", "集まり次第","主催者決定"]
    static let EVENT_TYPE_LIST: [String] = ["こだわらない","男性のみ","女性のみ"]
    static let GROUP_FLG_LIST: [String] = ["未選択","主催グループ","参加希望中"]

    static let EVENT_PRESENT_POINT: [String] = ["未選択", "100P","200P","300P","400P","500P","600P","700P","800P","900P","1000P"]
    static let PRESENT_POINT: [String] = ["0", "100","200","300","400","500","600","700","800","900","1000"]

    static let EVENT_PERIOD_LIST: [String] = ["未選択", "2日","3日","4日","5日","6日","7日","14日"]
    static let PERIOD_POINT: [String] = ["0", "0","200","400","600","800","1000","2000"]

    static let EVENT_PEPLE_LIST: [String] = ["未選択", "4人","5人","6人","7人","8人"]
    static let PEPLE_POINT: [String] = ["0", "0","200","400","600","800"]
    
    static let REPORT_LIST: [String] = ["誹謗中傷や暴言","営業・求人行為","商用利用目的","ビジネスへの勧誘","他サイトの「サクラ」","登録写真が芸能人画像","ストーカー行為","その他"]
    static let SEARCH_AGE_LIST: [String] = ["未選択","18〜24","25〜29","30〜34","35〜39","40〜44","45〜49","50〜54","55〜59","60〜"]

    static let RANK_NAME_LIST: [String] = ["スタンダード","ブロンズ","シルバー","ゴールド","プラチナ"]
    static let RANK_STEP_LIST: [String] = ["0","500000","1000000","1500000","2000000"]
    static let POINT_HISTORY: [String] = ["ポイント交換","ポイント購入","グループ賞金","ランクアップ報酬","目標達成報酬","いいね","メッセージ","グループ作成","グループ招待","つぶやき","使用","プレゼント"]
    static let GROUP_LABEL: [String] = ["","開催中","集計中","参加済"]

    //
    init(){
        
    }
    
}

