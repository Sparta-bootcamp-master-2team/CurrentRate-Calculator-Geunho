//
//  CachedRateDataManager.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/22/25.
//

import CoreData
import UIKit

final class CachedRateDataManager {
    
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer) {
        self.container = container
    }
    
    func saveRates(_ rate: [String: Double], timeStamp: Int64) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CachedRate", in: self.container.viewContext) else { return }
        let cachedRates = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        cachedRates.setValue(rate, forKey: "rate")
        cachedRates.setValue(timeStamp, forKey: "timeStamp")
        
        do {
            try self.container.viewContext.save()
            print("데이터 캐시 저장 성공")
        } catch {
            print("데이터 캐시 저장 실패")
        }
    }
    
    func loadCachedRates() -> (timeStamp: Int64, rates: [String: Double]) {
        var timeStamp: Int64 = 0
        var rateMap: [String: Double] = [:]
        
        do {
            let request: NSFetchRequest<CachedRate> = CachedRate.fetchRequest()
            let cachedDatas = try self.container.viewContext.fetch(request)
            for cachedData in cachedDatas {
                if let code = cachedData.currencyCode {
                    rateMap[code] = cachedData.rate
                }
                timeStamp = cachedData.timeStamp
            }
        } catch {
            print("데이터 캐시 로드 실패: \(error)")
        }
        print(timeStamp, rateMap)
        return (timeStamp, rateMap)
    }
}
