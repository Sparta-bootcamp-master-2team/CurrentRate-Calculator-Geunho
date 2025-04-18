//
//  CalculatorViewController.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/16/25.
//

import UIKit
import SnapKit
import Alamofire

final class CalculatorViewController: UIViewController {
    
    var rateItem: RateItem
    
    // MARK: - UI Components
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        textField.placeholder = "금액을 입력하세요"
        return textField
    }()
    
    private lazy var convertButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("환율 계산", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(convertButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.text = "계산 결과가 여기에 표시됩니다"
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setupTapGesture()
    }
    
    // MARK: - Initializers
    init(rateItem: RateItem) {
        self.rateItem = rateItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI & Layout
    private func setUI() {
        view.backgroundColor = .systemBackground
        title = "환율 계산기"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        [labelStackView, amountTextField, convertButton, resultLabel].forEach {
            view.addSubview($0)
        }
        
        [currencyLabel, countryLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
    }
    
    private func setLayout() {
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.centerX.equalToSuperview()
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(labelStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }
        
        convertButton.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(convertButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - Action
    /// 키보드 해제
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func convertButtonClicked() {
        
        guard let amount = Double(amountTextField.text ?? "") else {
            showInvalidInputAlert()
            return
        }
        
        // fetchNewExchangeRate에서 최신 환율 값을 받아온 후 계산 실행
        fetchNewExchangeRate(completion: { [weak self] in
            guard let self = self else { return }
            let computedAmount = amount * self.rateItem.value
            let result = ("$\(amount.toDigits(2)) → \(computedAmount.toDigits(2)) \(self.rateItem.currencyCode)")
            self.resultLabel.text = result
        })
    }
    
    // MARK: - Private Methods
    /// TapGesture 추가, tapGesture.cancelsTouchesInView = false로 뷰 내 터치 정상적으로 동작
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    /// 해당 currencyCode에 맞는 환율 정보 새로 업데이트
    private func fetchNewExchangeRate(completion: @escaping () -> Void) {
        NetworkManager.shared.fetchData { [weak self] (result: Result<ExchangeRateResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let exchangeResponse):
                    if let newValue  = exchangeResponse.rates[self.rateItem.currencyCode] {
                        self.rateItem.value = newValue
                        print("newValue: \(newValue)")
                        completion()
                    } else {
                        self.showNetworkErrorAlert()
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    
                    self.showNetworkErrorAlert()
                }
            }
        }
    }
    
    private func showInvalidInputAlert() {
        let alert = UIAlertController(title: "오류", message: "올바른 숫자를 입력해주세요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    private func showNetworkErrorAlert() {
        let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: - Internal Methods
    // Caculator View 정보 설정
    func configure(rateItem: RateItem) {
        currencyLabel.text = rateItem.currencyCode
        countryLabel.text = rateItem.countryName
        print(rateItem.currencyCode, rateItem.countryName)
    }
}

