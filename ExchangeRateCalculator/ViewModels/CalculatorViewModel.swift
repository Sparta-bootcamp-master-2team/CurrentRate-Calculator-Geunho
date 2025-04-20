//  CalculatorViewModel.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/17/25.
//

import Foundation
import Combine

final class CalculatorViewModel: ViewModelProtocol, ObservableObject {
    
    init(rateItem: RateItem) {
        self.rateItem = rateItem
    }
    
    typealias Action = ExchangeRateAction
    typealias State = ExchangeRateState
    
    var action: ((ExchangeRateAction) -> Void)?
    
    @Published var state: ExchangeRateState = .idle
    @Published var rateItem: RateItem
    @Published var resultText: String?
    @Published var currencyLabelText: String?
    @Published var countryLabelText: String?
    @Published var textInput: String = ""
    
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
                    print(exchangeResponse.timeStamp)
                    // 새로 받은 값
                    if let newValue  = exchangeResponse.rates[self.rateItem.currencyCode] {
                        
                        self.rateItem.value = newValue
                        
                        let computedAmount = amount * self.rateItem.value
                        print(computedAmount)
                        self.resultText = ("$\(amount.round(2).toDigits(2)) → \(computedAmount.round(2).toDigits(2)) \(self.rateItem.currencyCode)")
                        
                        self.state = .loaded([self.rateItem])
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    self.state = .error
                }
            }
        }
    }
    
    func configure() {
        currencyLabelText = rateItem.currencyCode
        countryLabelText = rateItem.countryName
    }
    
}
