//
//  ExchangeRateCellViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/21/25.
//

import Foundation
import Combine

class ExchangeRateCellViewModel {
    
    private let coreData = CoreDataManager()
    @Published var rateItem: RateItem
    @Published var currencyLabelText: String?
    @Published var rateLabelText: String?
    @Published var countryLabelText: String?
    @Published var isFavorite: Bool
    
    // 버튼 클릭 이벤트
    let favoriteTogglePublisher = PassthroughSubject<(String, Bool), Never>()
    
    init(rateItem: RateItem) {
        self.rateItem = rateItem
        self.isFavorite = rateItem.isFavorite
    }
    
    /// Cell 정보 설정
    func configure() {
        currencyLabelText = rateItem.currencyCode
        rateLabelText = rateItem.value.toDigits(4)
        countryLabelText = rateItem.countryName
    }
    
    /// 즐겨찾기 상태 설정
    func setFavoriteStatus() {
        rateItem.isFavorite.toggle()
        self.isFavorite = rateItem.isFavorite
        if rateItem.isFavorite {
            coreData.createData(currencyCode: rateItem.currencyCode)
        } else {
            coreData.deleteData(selectedCode: rateItem.currencyCode)
        }
        // 클릭 이벤트 send
        favoriteTogglePublisher.send((rateItem.currencyCode, rateItem.isFavorite))
    }
}
