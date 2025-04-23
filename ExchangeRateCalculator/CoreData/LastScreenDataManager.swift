//
//  LastScreenDataManager.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/23/25.
//

import CoreData
import UIKit

final class LastScreenDataManager {
    
    static let shared = LastScreenDataManager()
    
    private let container: NSPersistentContainer
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    func saveLastScreen(name: String) {
        
        // 기존 데이터 삭제
        let request: NSFetchRequest<NSFetchRequestResult> = LastScreen.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? container.viewContext.execute(deleteRequest)
        
        
        guard let entity = NSEntityDescription.entity(forEntityName: "LastScreen", in: self.container.viewContext) else { return }
        
        // 새 데이터 저장
        let screen = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        screen.setValue(name, forKey: "name")
        
        do {
            try self.container.viewContext.save()
            print("화면 저장 성공")
        } catch {
            print("화면 저장 실패")
        }
    }
    
    func loadLastScreen() -> String? {
        var lastScreen: String?
        
        do {
            let lastScreen = try self.container.viewContext.fetch(LastScreen.fetchRequest())
        } catch {
            print("읽기 실패")
        }
        return lastScreen
    }
}
