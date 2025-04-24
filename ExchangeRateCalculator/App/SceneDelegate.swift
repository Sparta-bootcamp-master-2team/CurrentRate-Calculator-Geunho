//
//  SceneDelegate.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // 마지막 화면 정보 로딩
        let lastScreen = LastScreenDataManager.shared.loadLastScreen() ?? "ExchangeRateView"
        let rootVC: UIViewController
        
        if lastScreen == "ExchangeRateView" {
            rootVC = ExchangeRateViewController()
            window.rootViewController = UINavigationController(rootViewController: rootVC)
        } else {
            // CoreData의 name 값에서 currencyCode, value 가져옴
            let data = lastScreen.components(separatedBy: " ")
            let currencyCode = data[1]
            let value = data[2]
            let rateItem = RateItem(currencyCode: currencyCode, value: Double(value)!)
            // CalculatorView 설정
            let pushVC = CalculatorViewController(viewModel: CalculatorViewModel(rateItem: rateItem))
            let nav = UINavigationController(rootViewController: ExchangeRateViewController())
            window.rootViewController = nav
            nav.pushViewController(pushVC, animated: false)
        }
            
        window.makeKeyAndVisible()
        self.window = window
    }
}



