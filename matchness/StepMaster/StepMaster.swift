//
//  StepMaster.swift
//  matchness
//
//  Created by 中村篤史 on 2022/02/09.
//  Copyright © 2022 a2c. All rights reserved.
//

import Foundation
import HealthKit

//struct ListRowItem: Decodable {
//    var id: String
//    var datetime: Date
//    var count: String
//}

protocol StepMasterDelegate {
    func stepCount(_ count: Double)
}

class StepMaster: ObservableObject {
    
//    var dataSource:[ListRowItem] = []
    
    var count:Double = 0.0
    var delegate: StepMasterDelegate?
    
    func get(_ fromDate: Date, _ toDate: Date)  {
 
        let healthStore = HKHealthStore()
        let readTypes = Set([
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount )!
        ])
        
        healthStore.requestAuthorization(toShare: [], read: readTypes, completion: { success, error in
            
            if success == false {
                print("データにアクセスできません")
                return
            }
            
            let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: fromDate as Date, end: toDate as Date, options: .strictStartDate)

            
            let query = HKStatisticsQuery(quantityType: type,quantitySamplePredicate: predicate,options: .cumulativeSum) { (query, statistics, error) in
                  var value: Double = 0
                  if error != nil {
                      print("something went wrong")
                  } else if let quantity = statistics?.sumQuantity() {
                      value = quantity.doubleValue(for: HKUnit.count())
                      print("LPLPLPLPLPLPLPLPLPLPLPLPLPPL")
                      dump(value)
                      self.count = value
                      self.delegate?.stepCount(value)
                  }
            }
            
            
            
//
//            // 歩数を取得
//            let query = HKSampleQuery(sampleType: HKSampleType.quantityType(forIdentifier: .stepCount)!,
//                                           predicate: HKQuery.predicateForSamples(withStart: fromDate, end: toDate, options: []),
//                                           limit: HKObjectQueryNoLimit,
//                                           sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]){ (query, results, error) in
//
//                guard error == nil else { print("error"); return }
//                if let tmpResults = results as? [HKQuantitySample] {
//                    // 取得したデータを１件ずつ ListRowItem 構造体に格納
//                    // ListRowItemは、dataSource配列に追加します。ViewのListでは、この dataSource配列を参照して歩数を表示します。
//
//
//                    for item in tmpResults {
//                        let listItem = ListRowItem(
//                            id: item.uuid.uuidString,
//                            datetime: item.endDate,
//                            count: String(item.quantity.doubleValue(for: .count()))
//                        )
//                        print("LPLPLPLPLPLPLPLPLPLPLPLPLPPL")
//                        dump(listItem)
//                        self.dataSource.append(listItem)
//                    }
//                }
//            }
            healthStore.execute(query)
        })
    }
}
