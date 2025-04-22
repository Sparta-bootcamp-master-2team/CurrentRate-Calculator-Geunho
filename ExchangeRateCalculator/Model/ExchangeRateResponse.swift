//
//  CurrentRate.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import Foundation

struct ExchangeRateResponse: Codable {
    let rates: [String: Double]
    let timeStamp: String
    
    enum CodingKeys: String, CodingKey {
        case rates
        case timeStamp = "time_last_update_utc"
    }
}
