//
//  Favorites+CoreDataClass.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/20/25.
//
//

import Foundation
import CoreData

@objc(Favorites)
public class Favorites: NSManagedObject {
    public static let className = String(describing: Favorites.self)
    
    public enum Key {
        static let currencyCode = "currencyCode"
    }
}
