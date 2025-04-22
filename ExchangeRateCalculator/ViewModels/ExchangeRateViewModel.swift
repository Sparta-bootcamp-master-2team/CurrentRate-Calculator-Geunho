//
//  MainViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/17/25.
//

import Foundation

final class ExchangeRateViewModel: ViewModelProtocol {
    
    private let coreData = CoreDataManager()
    private var favoriteCodes = [String]()
    
    init() {
        // 즐겨찾기된 currencyCode 저장
        favoriteCodes = coreData.readAllData()
    }
    
    typealias Action = ExchangeRateAction
    typealias State = ExchangeRateState
    
    var action: ((ExchangeRateAction) -> Void)?
    
    @Published var state: ExchangeRateState = .idle
    var rateItems = [RateItem]()
    var tempRateItems = [RateItem]()
    
    func setExchangeRate(_ action: ExchangeRateAction) {
        
        switch action {
        case .fetch:
            NetworkManager.shared.fetchData { [weak self] (result: Result<ExchangeRateResponse, Error>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        
                        let items = response.rates.map {
                            RateItem(currencyCode: $0.key, value: $0.value)
                        }.sorted {
                            $0.currencyCode < $1.currencyCode
                        }
                        
                        self.rateItems = items
                        self.tempRateItems = items
                        self.state = .loaded(items)
                        self.fetchFavorites(self.favoriteCodes)
                        
                    case .failure(let error):
                        print("데이터 로드 실패: \(error)")
                        self.state = .error
                    }
                }
            }
        case .filter(let text):
            guard !text.isEmpty else {
                self.rateItems = tempRateItems
                self.state = .loaded(self.rateItems)
                return
            }
            
            self.rateItems = tempRateItems.filter {
                // localizedCaseInsensitiveContains -> 대소문자 구분 X, 현지화
                return $0.currencyCode.localizedCaseInsensitiveContains(text) ||
                $0.countryName.localizedCaseInsensitiveContains(text)
            }
            self.state = .loaded(self.rateItems)
        }
    }
    
    /// 각 요소에 즐겨찾기 상태 적용
    func fetchFavorites(_ favoriteCodes: [String]) {
        for i in 0..<rateItems.count {
            if favoriteCodes.contains(rateItems[i].currencyCode) {
                rateItems[i].isFavorite = true
                print(rateItems[i])
            }
        }
        
        rateItems.sort {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite
            }
            return $0.currencyCode < $1.currencyCode
        }
        tempRateItems = rateItems
        state = .loaded(rateItems)
    }
    
    /// 클릭 시 즐겨찾기 상태 변경
    func updateFavorite(currencyCode: String, isFavorite: Bool) {
        if let index = rateItems.firstIndex(where: { $0.currencyCode == currencyCode }) {
            rateItems[index].isFavorite = isFavorite
            rateItems.sort {
                if $0.isFavorite != $1.isFavorite {
                    return $0.isFavorite
                }
                return $0.currencyCode < $1.currencyCode
            }
            tempRateItems = rateItems
            state = .loaded(rateItems)
        }
    }
}
