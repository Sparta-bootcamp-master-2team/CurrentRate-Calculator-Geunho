//
//  OldCachedRate+CoreDataProperties.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/23/25.
//
//

import Foundation
import CoreData


extension OldCachedRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OldCachedRate> {
        return NSFetchRequest<OldCachedRate>(entityName: "OldCachedRate")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var rate: Double
    @NSManaged public var timeStamp: Int64

}

extension OldCachedRate : Identifiable {

}
