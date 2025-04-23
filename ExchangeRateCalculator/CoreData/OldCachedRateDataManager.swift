//
//  OldCachedRateDataManager.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/23/25.
//

import CoreData
import UIKit

final class OldCachedRateDataManager {
    
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer) {
        self.container = container
    }
    
    func saveRates(_ rateDatas: [String: Double], timeStamp: Int64) {
        
        // 기존 데이터 삭제
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = OldCachedRate.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? container.viewContext.execute(deleteRequest)
        
        // 새 데이터 설정
        for (currencyCode, rate) in rateDatas {
            guard let entity = NSEntityDescription.entity(forEntityName: "OldCachedRate", in: self.container.viewContext) else { continue }
            let cachedRate = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
            cachedRate.setValue(currencyCode, forKey: "currencyCode")
            cachedRate.setValue(rate, forKey: "rate")
            cachedRate.setValue(timeStamp, forKey: "timeStamp")
        }
        
        do {
            try self.container.viewContext.save()
            print("데이터 캐시 저장 성공")
        } catch {
            print("데이터 캐시 저장 실패: \(error)")
        }
    }
    
    // ExchangeRateResponse 형태로 캐시 데이터 로드
    func loadCachedRates() -> ExchangeRateResponse {
        var timeStamp: Int64 = 0
        var rates: [String: Double] = [:]
        
        do {
            let request: NSFetchRequest<OldCachedRate> = OldCachedRate.fetchRequest()
            let cachedDatas = try self.container.viewContext.fetch(request)
            for cachedData in cachedDatas {
                if let code = cachedData.currencyCode {
                    rates[code] = cachedData.rate
                }
                timeStamp = cachedData.timeStamp
            }
        } catch {
            print("데이터 캐시 로드 실패: \(error)")
        }
        return ExchangeRateResponse(timeStamp: timeStamp, rates: rates)
    }
}
