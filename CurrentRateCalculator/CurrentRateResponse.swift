//
//  CurrentRate.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import Foundation

struct CurrentRateResponse: Codable {
    let baseCode: String
    let rates: [String: Double]

    
    enum CodingKeys: String, CodingKey {
        case baseCode = "base_code"
        case rates
    }
}
