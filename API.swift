//
//  API.swift
//  matchness
//
//  Created by 中村篤史 on 2022/01/14.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation
import Alamofire


public typealias SuccessHandler<T> = (_ responseModel: T) -> Void
public typealias FailureHandler = (_ error: Error) -> Void

private let JSONTYPE = "application/json"

class API<T: Decodable> {
    public var accessToken: String = ""
    
    
    class func requestHttp(_ module: APIModule, parameters: Parameters? = nil, success: SuccessHandler<T>?, failure: FailureHandler?) {
        requestHttp(
            module.url,
            parameters: parameters,
            success: success,
            failure: failure
        )
    }

    class func requestHttp(_ url: String,
                           method: HTTPMethod = .post,
                           parameters: Parameters? = nil,
                           encoding: ParameterEncoding = URLEncoding.default,
                           headers: HTTPHeaders? = nil,
                           success: SuccessHandler<T>?,
                           failure: FailureHandler?) {

        // TODO: トークンセット、取得の仕組みを見直し
        // AuthorizationAdapterの使用を検討
//        guard let accessToken: String = UserDefaults.standard.object(forKey: "pasch_api_token") as? String else { return }
        
        var api_key = userDefaults.object(forKey: "api_token") as? String
        
        print("ssss", api_key)
        
        var Authorization = api_key != nil ? "Bearer " + api_key! : ""
        let requestHeader: HTTPHeaders = [
            "Accept" : "application/json",
            "Authorization" : Authorization,
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        //暫定対応 開発ビルドなら、開発API用の Login User Id を追加、accessTokenの代わり
        var parameters = parameters
        let enc: ParameterEncoding = JSONEncoding.default
        
        print("API [\(method.rawValue): \(url) ]")
        print("(Param: \(String(describing: parameters)))")
        
        AF.request(url, method: method, parameters: parameters, encoding: enc, headers: requestHeader)
            .validate(statusCode: 200..<300)
            .validate(contentType: [JSONTYPE])
            .responseData { response in
                switch response.result {
                case .success:
//                    dump(parameters)
                    guard let success = success else { return }
                    guard let data = response.data else { return }
                    
                    let statusCode = response.response?.statusCode ?? -1
                    let decoder: JSONDecoder = JSONDecoder()
                    
                    guard let model = try? decoder.decode(T.self, from: data) else {
                        print("モデルエラー [\(statusCode)]: \(url)")
//                        self.jsonDump(data)
                        return
                    }
                    
                    print("SUCCESS [Status: \(statusCode)] (URL: \(url)")
                    success(model)
                case .failure(let error):
                    print("モデルエラーーーーー")
//                    dump(parameters)
                    guard let failure = failure else { return }
                    failure(error)
                }
            }
    }
    

//    class func parseJSON(from data: FakeData,success: SuccessHandler<T>) {
//        parseJSON(from: data.rawValue, success: success)
//    }

    class func parseJSON(
        from filename: String,
        success: SuccessHandler<T>
    ) {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            print("content of json: \(data)")
            print("TYPE by json: ", T.self)

            guard let model = try? JSONDecoder().decode(T.self, from: data)
            else {
                print("Json to Model Conversion Error: \(url)")
//                self.jsonDump(data)
                return
            }
            success(model)
        } catch {
            print("Error reading json: \(error)")
        }
    }
}

extension API {
    // モデル変換の失敗時のみ実行
    private class func jsonDump(_ jsonData: Data?) {
        
        guard let jsonData = jsonData else { return }
//        dump(jsonData)
        let json: String? = String(data: jsonData, encoding: .utf8)
        
        guard let data = json?.data(using: .utf8) else { return }
        
        let jsonString = try? JSONSerialization.jsonObject(with: data)
//        print("JSON DUMP : \(String(describing: jsonString))")
//        dump(jsonString)
    }
}
