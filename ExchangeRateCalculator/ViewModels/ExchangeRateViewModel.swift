//
//  MainViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/17/25.
//

import Foundation

final class ExchangeRateViewModel: ViewModelProtocol, ObservableObject {
    
    private let coreData = CoreDataManager()
    private var favoriteCodes = [String]()
    
    init() {
        favoriteCodes = coreData.readAllData()
    }
    
    typealias Action = ExchangeRateAction
    typealias State = ExchangeRateState
    
    var action: ((ExchangeRateAction) -> Void)?
    
    @Published var state: ExchangeRateState = .idle
    @Published var rateItems = [RateItem]()
    @Published var tempRateItems = [RateItem]()
    // Test
    @Published var titleText: String = "환율 정보"
    
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
                return
            }
            
            self.rateItems = tempRateItems.filter {
                // localizedCaseInsensitiveContains -> 대소문자 구분 X, 현지화
                return $0.currencyCode.localizedCaseInsensitiveContains(text) ||
                $0.countryName.localizedCaseInsensitiveContains(text)
            }
        }
    }
    
    private func fetchFavorites(_ favoriteCodes: [String]) {
        for i in 0..<rateItems.count {
            if favoriteCodes.contains(rateItems[i].currencyCode) {
                rateItems[i].isFavorite = true
                print(rateItems[i], rateItems[i].isFavorite)
            }
        }
    }
}
