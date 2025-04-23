//
//  LastScreen+CoreDataProperties.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/23/25.
//
//

import Foundation
import CoreData


extension LastScreen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastScreen> {
        return NSFetchRequest<LastScreen>(entityName: "LastScreen")
    }

    @NSManaged public var name: String

}

extension LastScreen : Identifiable {

}
