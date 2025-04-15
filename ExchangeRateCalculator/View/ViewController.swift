//
//  ViewController.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController {
    
    var rateItems = [RateItem]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        // 테이블 뷰에다가 테이블 뷰 셀 등록
        tableView.register(ExchangeRateCell.self, forCellReuseIdentifier: ExchangeRateCell.id)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        setUI()
        setLayout()
        fetchExchangeRateData()
    }
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
    }
    
    private func setLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // 서버 데이터를 불러오는 메서드 (Alamofire)
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, AFError>) -> Void) {
        
        AF.request(url).responseDecodable(of: T.self) { response in
            completion(response.result)
        }
        
    }
    
    private func fetchExchangeRateData() {
        let urlComponents = URLComponents(string: "https://open.er-api.com/v6/latest/USD")
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: Result<ExchangeRateResponse, AFError>) in
            guard let self else { return }
            
            switch result {
            case .success(let exchangeResponse):
                for item in exchangeResponse.rates {
                    print(item)
                }
                self.rateItems = exchangeResponse.rates.map { RateItem(currencyCode: $0.key, value: $0.value) }
                    .sorted { $0.currencyCode < $1.currencyCode }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("데이터 로드 실패: \(error)")
                    
                let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rateItems[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCell.id) as? ExchangeRateCell else {
            return UITableViewCell()
        }
        cell.configureCell(rateItem: rateItems[indexPath.row])
        return cell
    }
}
