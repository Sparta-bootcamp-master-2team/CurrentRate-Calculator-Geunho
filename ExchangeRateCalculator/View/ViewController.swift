//
//  ViewController.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import UIKit
import SnapKit
import Alamofire

final class ViewController: UIViewController {
    
    var rateItems = [RateItem]()
    var tempRateItems = [RateItem]()
        
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "통화 검색"
        bar.searchBarStyle = .minimal
        bar.delegate = self
        bar.autocapitalizationType = .none
        return bar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        // 테이블 뷰에다가 테이블 뷰 셀 등록
        tableView.register(ExchangeRateCell.self, forCellReuseIdentifier: ExchangeRateCell.id)
        return tableView
    }()
    
    private lazy var emptyTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "검색 결과 없음"
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        fetchExchangeRateData()
    }
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        
        [searchBar, tableView, emptyTextLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyTextLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tableView)
        }
    }
    
    // 서버 데이터 불러오기 (Alamofire)
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(url).responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // 환율 정보 불러오기
    private func fetchExchangeRateData(text: String? = nil) {
        let urlComponents = URLComponents(string: "https://open.er-api.com/v6/latest/USD")
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: Result<ExchangeRateResponse, AFError>) in
            guard let self else { return }
            
            switch result {
            case .success(let exchangeResponse):
                DispatchQueue.main.async {
                // RateItem 초기화
                    self.rateItems = exchangeResponse.rates.map { RateItem(currencyCode: $0.key, value: $0.value) }
                        .sorted { $0.currencyCode < $1.currencyCode }
                    self.tempRateItems = self.rateItems
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("데이터 로드 실패: \(error)")
                
                DispatchQueue.main.async {
                    // Alert 창
                    let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}


// MARK: - UITableView
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calculatorView = CalculatorViewController(rateItem: rateItems[indexPath.row])
        self.navigationController?.pushViewController(calculatorView, animated: true)
        calculatorView.configure(rateItem: rateItems[indexPath.row])
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
        cell.configure(rateItem: item)
        return cell
    }
}

// MARK: - UISearchBar
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        filterLoadedData(text: text)
        
        emptyTextLabel.isHidden = !rateItems.isEmpty

        self.tableView.reloadData()
    }
    
    private func filterLoadedData(text: String) {

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
