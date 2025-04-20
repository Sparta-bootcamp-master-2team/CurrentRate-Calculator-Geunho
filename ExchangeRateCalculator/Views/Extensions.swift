//
//  ShowAlert.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/19/25.
//

import UIKit

extension UIViewController {
    /// Alert창 생성 후 표시
    func showAlert(alertTitle: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default))
        self.present(alert, animated: true)
    }
}

extension Double {
    /// 소수점 자릿수 설정
    func toDigits(_ digit: Int) -> String {
        return String(format: "%.\(digit)f", self)
    }
    
    /// 해당 자릿수에서 반올림
    func round(_ to: Double) -> Double {
        let multiplier = pow(10.0, to)
        let rounded = (self * multiplier).rounded() / multiplier
        return rounded
    }
}
