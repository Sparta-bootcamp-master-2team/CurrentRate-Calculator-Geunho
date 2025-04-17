//
//  MainViewController.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import UIKit
import SnapKit
import Alamofire

final class ExchangeRateViewController: UIViewController {
     
    var rateItems = [RateItem]()
    var tempRateItems = [RateItem]()
    
    // MARK: - UI Components
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
        setupTapGesture()
    }
    
    // MARK: - UI & Layout
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
    

    // MARK: - Action
    /// 키보드 해제
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Private Methods
    /// TapGesture 추가, tapGesture.cancelsTouchesInView = false로 뷰 내 터치 정상적으로 동작
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func fetchExchangeRateData() {

        NetworkManager.shared.fetchData { [weak self] (result: Result<ExchangeRateResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let items = response.rates.map {
                        RateItem(currencyCode: $0.key, value: $0.value)
                    }.sorted { $0.currencyCode < $1.currencyCode }
                    
                    self.rateItems = items
                    self.tempRateItems = items
                    self.emptyTextLabel.isHidden = !items.isEmpty
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    self.showNetworkErrorAlert()
                }
            }
        }
    }
    
    private func showNetworkErrorAlert() {
        let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}


// MARK: - UITableView
extension ExchangeRateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calculatorView = CalculatorViewController(rateItem: rateItems[indexPath.row])
        self.navigationController?.pushViewController(calculatorView, animated: true)
        calculatorView.configure(rateItem: rateItems[indexPath.row])
    }
}

extension ExchangeRateViewController: UITableViewDataSource {
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
extension ExchangeRateViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        filterLoadedData(text: text)
        
        emptyTextLabel.isHidden = !rateItems.isEmpty

        self.tableView.reloadData()
    }
    
    // viewmodel
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}

// 뷰모델 역할
// 바인딩 방법 종류(어떻게하는지)
// Combine, RxSwift
// @Observable
