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
    
    // 현재 timeStamp
    var currentTimeStamp: Int64 = 0

    
    init() {
        // 즐겨찾기된 currencyCode 저장
        favoriteCodes = favoritesDataManager.readAllData()
        
        // 캐시 데이터에서 timeStamp 불러옴
        currentTimeStamp = cachedDataManager.loadCachedRates().timeStamp
        
        // 캐시 데이터
        cachedData = cachedDataManager.loadCachedRates()
        
        // 테스트 위해 Old에 MockData 저장
//        oldCachedDataManager.saveRates(MockData().rates, timeStamp: MockData().timeStamp)
        
        // 이전 데이터 (Old)
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
                        
                        // 받아오는 데이터의 timeStamp와 현재 timeStamp 비교
                        if response.timeStamp > self.currentTimeStamp {
                            // Old에 기존 cachedData 저장
                            self.oldCachedDataManager.saveRates(self.cachedData.rates, timeStamp: self.cachedData.timeStamp)
                            
                            items = self.compareWithPreviousRates(rates: response.rates)
                            
                            // 캐시에 새 데이터 저장 (새로운 timeStamp일 때)
                            self.cachedDataManager.saveRates(response.rates, timeStamp: response.timeStamp)
                            
                            self.currentTimeStamp = response.timeStamp
                        } else {
                            // timeStamp 변경 없을 시 기존 Old와 cachedData 비교
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

