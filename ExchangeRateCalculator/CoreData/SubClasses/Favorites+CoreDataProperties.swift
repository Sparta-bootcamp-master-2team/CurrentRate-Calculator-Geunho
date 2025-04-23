//
//  Favorites+CoreDataProperties.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/20/25.
//
//

import Foundation
import CoreData


extension Favorites {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorites> {
        return NSFetchRequest<Favorites>(entityName: "Favorites")
    }

    @NSManaged public var currencyCode: String?

}

extension Favorites : Identifiable {

}
