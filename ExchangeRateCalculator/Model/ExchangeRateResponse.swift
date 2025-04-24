//
//  CurrentRate.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import Foundation

struct ExchangeRateResponse: Codable {
    let timeStamp: Int64
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case rates
        case timeStamp = "time_next_update_unix"
    }
}
