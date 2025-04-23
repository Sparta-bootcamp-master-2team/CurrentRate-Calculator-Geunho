//
//  MainViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/17/25.
//

import Foundation

final class ExchangeRateViewModel: ViewModelProtocol {
    
    private let favoritesDataManager = FavoritesDataManager()
    private let cachedDataManager = CachedRateDataManager()
    private let oldCachedDataManager = OldCachedRateDataManager()
    
    private let cachedData: ExchangeRateResponse
    private let oldCachedData: ExchangeRateResponse

    private var favoriteCodes = [String]()
    
    var currentTimeStamp: Int64 = 0

    
    init() {
        // 즐겨찾기된 currencyCode 저장
        favoriteCodes = favoritesDataManager.readAllData()
        
        currentTimeStamp = cachedDataManager.loadCachedRates().timeStamp
        
        cachedData = cachedDataManager.loadCachedRates()
        
        oldCachedDataManager.saveRates(MockData().rates, timeStamp: MockData().timeStamp)
        oldCachedData = oldCachedDataManager.loadCachedRates()
    }
    
    typealias Action = ExchangeRateAction
    typealias State = ExchangeRateState
    
    var action: ((ExchangeRateAction) -> Void)?
    
    @Published var state: ExchangeRateState = .idle
    var rateItems = [RateItem]()
    var allRateItems = [RateItem]()
        
    func setExchangeRate(_ action: ExchangeRateAction) {
        
        switch action {
        case .fetch:
            NetworkManager.shared.fetchData { [weak self] (result: Result<ExchangeRateResponse, Error>) in
                guard let self = self else { return }
                                
                DispatchQueue.main.async { [self] in
                    switch result {
                    case .success(let response):
                        
                        var items = response.rates.map {
                            RateItem(currencyCode: $0.key, value: $0.value)
                        }.sorted {
                            $0.currencyCode < $1.currencyCode
                        }
                        
                        if response.timeStamp > self.currentTimeStamp {
                            self.oldCachedDataManager.saveRates(self.cachedData.rates, timeStamp: self.cachedData.timeStamp)
                            
                            items = self.compareWithPreviousRates(rates: response.rates)
                            
                            // 캐시에 새 데이터 저장 (새로운 timeStamp일 때)
                            self.cachedDataManager.saveRates(response.rates, timeStamp: response.timeStamp)
                            
                            self.currentTimeStamp = response.timeStamp
                            print(response.timeStamp, self.currentTimeStamp)
                        } else {
                            print(response.timeStamp, self.currentTimeStamp)
                            items = self.compareWithPreviousRates(rates: self.cachedData.rates)
                        }
                        
                        self.allRateItems = items
                        self.fetchFavorites(self.favoriteCodes)
                        self.state = .loaded(self.rateItems)
                        
                        
                    case .failure(let error):
                        print("데이터 로드 실패: \(error)")
                        self.state = .error
                    }
                }
            }
        case .filter(let text):
            if text.isEmpty {
                self.rateItems = allRateItems
                self.state = .loaded(self.rateItems)
            } else {
                self.rateItems = allRateItems.filter {
                    // localizedCaseInsensitiveContains -> 대소문자 구분 X, 현지화
                    return $0.currencyCode.localizedCaseInsensitiveContains(text)
                    || $0.countryName.localizedCaseInsensitiveContains(text)
                }
                self.state = .loaded(self.rateItems)
            }
        }
    }
    
    /// 각 요소에 즐겨찾기 상태 적용 (fetch 시 한 번), rateItems 설정
    func fetchFavorites(_ favoriteCodes: [String]) {
        for i in 0..<allRateItems.count {
            if favoriteCodes.contains(allRateItems[i].currencyCode) {
                allRateItems[i].isFavorite = true
                print(allRateItems[i])
            }
        }
        
        allRateItems.sort {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite
            }
            return $0.currencyCode < $1.currencyCode
        }
        
        // rateItems 값 업데이트
        self.rateItems = allRateItems
    }
    
    /// 클릭 시 즐겨찾기 상태 변경
    func updateFavorite(currencyCode: String, isFavorite: Bool) {
        if let index = allRateItems.firstIndex(where: { $0.currencyCode == currencyCode }) {
            allRateItems[index].isFavorite = isFavorite
        }
        
        if let index = rateItems.firstIndex(where: { $0.currencyCode == currencyCode}) {
            rateItems[index].isFavorite = isFavorite
        }
        
        allRateItems.sort {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite
            }
            return $0.currencyCode < $1.currencyCode
        }
        
        rateItems.sort {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite
            }
            return $0.currencyCode < $1.currencyCode
        }
        // 업데이트 된 rateItems으로 reload
        state = .loaded(rateItems)
    }
    
    /// 이전 환율데이터와 비교하여 아이콘 표시 기준(ChangeDirection) 설정
    func compareWithPreviousRates(rates: [String: Double]) -> [RateItem] {
        let oldCachedRates = oldCachedData.rates
        var result: [RateItem] = []
        
        for (code, newValue) in rates {
            let oldValue = oldCachedRates[code] ?? newValue
            let diff = abs(newValue - oldValue)
            
            let direction: ChangeDirection
            if diff <= 0.01 {
                direction = .same
            } else {
                direction = newValue > oldValue ? .up : .down
            }
            result.append(RateItem(currencyCode: code, value: newValue, change: direction))
        }
        
        return result
    }
}

