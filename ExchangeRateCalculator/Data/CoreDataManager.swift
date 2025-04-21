//
//  CoreDataManager.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/20/25.
//

import CoreData
import UIKit

class CoreDataManager {
    
    private var container: NSPersistentContainer!
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    func createData(currencyCode: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: Favorites.className, in: self.container.viewContext) else { return }
        let newFavorites = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        newFavorites.setValue(currencyCode, forKey: Favorites.Key.currencyCode)
        
        do {
            try self.container.viewContext.save()
            print("저장 성공")
        } catch {
            print("저장 실패")
        }
    }
    
    func readAllData() -> [String] {
        var favoriteCodes = [String]()
        do {
            let favorites = try self.container.viewContext.fetch(Favorites.fetchRequest())
            for favorite in favorites as [NSManagedObject]{
                if let currencyCode = favorite.value(forKey: Favorites.Key.currencyCode) as? String {
                    favoriteCodes.append(currencyCode)
                }
            }
        } catch {
            print("읽기 실패")
        }
        return favoriteCodes
    }
    
    func deleteData(selectedCode: String) {
        let fetchRequest = Favorites.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currencyCode == %@", selectedCode)
        do {
            let result = try self.container.viewContext.fetch(fetchRequest)
            
            for data in result as [NSManagedObject] {
                self.container.viewContext.delete(data)
            }
            try self.container.viewContext.save()
            print("삭제 성공")
        } catch {
            print("삭제 실패")
        }
    }
}
