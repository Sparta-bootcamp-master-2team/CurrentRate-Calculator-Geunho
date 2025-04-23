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
        
        // ✅ 마지막 화면 정보 로딩
        let lastScreen = LastScreenDataManager.shared.loadLastScreen() ?? "ExchangeRateView"
        let rootVC: UIViewController
        
        if lastScreen == "ExchangeRateView" {
            rootVC = ExchangeRateViewController()
        } else {
            let data = lastScreen.components(separatedBy: " ")
            let currencyCode = data[1]
            let value = data[2]
            let rateItem = RateItem(currencyCode: currencyCode, value: Double(value)!)
            rootVC = CalculatorViewController(viewModel: CalculatorViewModel(rateItem: rateItem))
        }
        
        print("🟢 SceneDelegate - 진입 화면: \(lastScreen)")
        
        window.rootViewController = UINavigationController(rootViewController: rootVC)
        window.makeKeyAndVisible()
        self.window = window
    }
}



