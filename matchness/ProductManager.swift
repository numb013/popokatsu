import Foundation
import StoreKit
//import SwiftyStoreKit

private var productManagers : Set<ProductManager> = Set()

class ProductManager: NSObject, SKProductsRequestDelegate {

    private var completionForProductidentifiers : (([SKProduct]?,NSError?) -> Void)?

    /// 課金アイテム情報を取得
    class func productsWithProductIdentifiers(productIdentifiers : [String]!,completion:(([SKProduct]?,NSError?) -> Void)?){
        print("課金アイテム情報を取得")
        let productManager = ProductManager()
        productManager.completionForProductidentifiers = completion
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = productManager
        productRequest.start()
        productManagers.insert(productManager)
    }

    // MARK: - SKProducts Request Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("取得できませ")
        var error : NSError? = nil
        if response.products.count == 0 {
            error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"1プロダクトを取得できませんでした。"])
        }
        completionForProductidentifiers?(response.products, error)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        let error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"2プロダクトを取得できませんでした。"])
        completionForProductidentifiers?(nil,error)
        productManagers.remove(self)
    }

    func requestDidFinish(_ request: SKRequest) {
        productManagers.remove(self)
    }

    // MARK: - Utility
    // 価格情報を抽出
    class func priceStringFromProduct(product: SKProduct!) -> String {
        print("価格情報を抽出")
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price)!
    }
}
