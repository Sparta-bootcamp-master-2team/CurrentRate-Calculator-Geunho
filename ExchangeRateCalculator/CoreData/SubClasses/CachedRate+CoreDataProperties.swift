//
//  CachedRate+CoreDataProperties.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/22/25.
//
//

import Foundation
import CoreData


extension CachedRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedRate> {
        return NSFetchRequest<CachedRate>(entityName: "CachedRate")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var rate: Double
    @NSManaged public var timeStamp: Int64

}

extension CachedRate : Identifiable {

}
