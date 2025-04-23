//  CalculatorViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/17/25.
//

import Foundation
import Combine

enum CalculatorState {
    case loaded(String?)
    case error
}

final class CalculatorViewModel {
    
    init(rateItem: RateItem) {
        self.rateItem = rateItem
    }
    
    @Published var state: CalculatorState = .loaded(nil)
    @Published var rateItem: RateItem
    @Published var textInput: String = ""
    var resultText: String = ""
    
    var isButtonEnabled: AnyPublisher<Bool, Never> {
        $textInput
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .eraseToAnyPublisher()
    }
    
    /// 해당 currencyCode에 맞는 환율 정보 새로 업데이트
    func setNewExchangeRate(_ amount: Double) {
        
        NetworkManager.shared.fetchData { [weak self] (result: Result<ExchangeRateResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let exchangeResponse):
                    // 새로 받은 값
                    if let newValue  = exchangeResponse.rates[self.rateItem.currencyCode] {
                        
                        self.rateItem.value = newValue
                        
                        let computedAmount = amount * self.rateItem.value
                        print(computedAmount)
                        self.resultText = ("$\(amount.round(2).toDigits(2)) → \(computedAmount.round(2).toDigits(2)) \(self.rateItem.currencyCode)")
                        
                        self.state = .loaded(self.resultText)
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    self.state = .error
                }
            }
        }
    }
    
}
