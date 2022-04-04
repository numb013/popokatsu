import Foundation
import StoreKit

private let purchaseManagerSharedManager = PurchaseManager()

class PurchaseManager : NSObject,SKPaymentTransactionObserver {

    var delegate : PurchaseManagerDelegate?

    fileprivate var productIdentifier : String?
    fileprivate var isRestore : Bool = false

    /// シングルトン
    class func sharedManager() -> PurchaseManager{
        return purchaseManagerSharedManager;
    }

    /// 課金開始
    func startWithProduct(_ product : SKProduct){
        var errorCount = 0
        var errorMessage = ""

        if SKPaymentQueue.canMakePayments() == false {
            errorCount += 1
            errorMessage = "設定で購入が無効になっています。"
        }

        if self.productIdentifier != nil {
            errorCount += 10
            errorMessage = "課金処理中です。"
        }

        if self.isRestore == true {
            errorCount += 100
            errorMessage = "リストア中です。"
        }

        //エラーがあれば終了
        if errorCount > 0 {
            let error = NSError(domain: "PurchaseErrorDomain", code: errorCount, userInfo: [NSLocalizedDescriptionKey:errorMessage + "(\(errorCount))"])
            self.delegate?.purchaseManager?(self, didFailWithError: error)
            return
        }

        //未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            for transaction in transactions {
                if transaction.transactionState != .purchased {
                    continue
                }

                if transaction.payment.productIdentifier == product.productIdentifier {
                    if let window = UIApplication.shared.delegate?.window {
                        let ac = UIAlertController(title: nil, message: "\(product.localizedTitle)は購入処理が中断されていました。\nこのまま無料でダウンロードできます。", preferredStyle: .alert)
                        let action = UIAlertAction(title: "続行", style: UIAlertAction.Style.default, handler: {[weak self] (action : UIAlertAction!) -> Void in
                            if let weakSelf = self {
                                weakSelf.productIdentifier = product.productIdentifier
                                weakSelf.completeTransaction(transaction)
                            }
                            })
                        ac.addAction(action)
                        window!.rootViewController?.present(ac, animated: true, completion: nil)
                        return
                    }
                }
            }
        }

        //課金処理開始
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        self.productIdentifier = product.productIdentifier
    }

    /// リストア開始
    func startRestore(){
        if self.isRestore == false {
            self.isRestore = true
            SKPaymentQueue.default().restoreCompletedTransactions()
        }else{
            let error = NSError(domain: "PurchaseErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"リストア処理中です。"])
            self.delegate?.purchaseManager?(self, didFailWithError: error)
        }
    }

    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("AAAA課金状態が更新される")
        //課金状態が更新されるたびに呼ばれる
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing :
                //課金中
                print("課金中")
                break
            case .purchased :
                //課金完了
                print("課金完了")
                self.completeTransaction(transaction)
                break
            case .failed :
                //課金失敗
                print("課金失敗")
                self.failedTransaction(transaction)
                break
            case .restored :
                //リストア
                print("リストア")
                self.restoreTransaction(transaction)
                break
            case .deferred :
                //承認待ち
                print("承認待ち")
                self.deferredTransaction(transaction)
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("AAAAリストア失敗時に呼ばれる")
        //リストア失敗時に呼ばれる
        self.delegate?.purchaseManager?(self, didFailWithError: error as NSError?)
        self.isRestore = false
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("AAAAリストア完了時に呼ばれる")
        //リストア完了時に呼ばれる
        self.delegate?.purchaseManagerDidFinishRestore?(self)
        self.isRestore = false
    }



    // MARK: - SKPaymentTransaction process
    fileprivate func completeTransaction(_ transaction : SKPaymentTransaction) {
        print("AAAA課金終了")
        if transaction.payment.productIdentifier == self.productIdentifier {
            //課金終了
            self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                     print("AAAAトランザクション終了")
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
            self.productIdentifier = nil
        }else{
            print("AAAA以前中断された課金処理")
            //課金終了(以前中断された課金処理)
            self.delegate?.purchaseManager?(self, didFinishUntreatedPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
        }
    }
        
    fileprivate func failedTransaction(_ transaction : SKPaymentTransaction) {
        //課金失敗
        self.delegate?.purchaseManager?(self, didFailWithError: transaction.error as NSError?)
        self.productIdentifier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    fileprivate func restoreTransaction(_ transaction : SKPaymentTransaction) {
        print("AAAAリストアリストアリストア")
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　※設計に応じて変更
        self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction.original, decisionHandler: { (complete) -> Void in
            if complete == true {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }

    fileprivate func deferredTransaction(_ transaction : SKPaymentTransaction) {
        print("AAAA承認待ち承認待ち")
        //承認待ち
        self.delegate?.purchaseManagerDidDeferred?(self)
        self.productIdentifier = nil
    }
}


@objc protocol PurchaseManagerDelegate {
    //課金完了
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete : Bool) -> Void)!)
    //課金完了(中断していたもの)
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete : Bool) -> Void)!)
    //リストア完了
    @objc optional func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!)
    //課金失敗
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!)
    //承認待ち(ファミリー共有)
    @objc optional func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!)
}
