//
//  ExchangeRateCellViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/21/25.
//

import Foundation

class ExchangeRateCellViewModel: ObservableObject {
    
    @Published var rateItem: RateItem
    @Published var isFavorite: Bool
    @Published var currencyLabelText: String?
    @Published var rateLabelText: String?
    @Published var countryLabelText: String?

    init(rateItem: RateItem, isFavorite: Bool = false) {
        self.rateItem = rateItem
        self.isFavorite = isFavorite
        print(isFavorite)
    }
    
    /// Cell 정보 설정
    func configure() {
        currencyLabelText = rateItem.currencyCode
        rateLabelText = rateItem.value.toDigits(4)
        countryLabelText = rateItem.countryName
    }
}
