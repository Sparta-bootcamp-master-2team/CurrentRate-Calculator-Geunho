//
//  CalculatorViewController.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/16/25.
//

import UIKit
import SnapKit

class CalculatorViewController: UIViewController {
    
    let rateItem: RateItem
    
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
    }
    
    init(rateItem: RateItem) {
        self.rateItem = rateItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        
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
    
    @objc func convertButtonClicked() {
        if let amount = Double(amountTextField.text!) {
            let computedAmount = Double(amount) * rateItem.value
            let result = "$\(amount) -> \(computedAmount) \(rateItem.currencyCode)"
            print(result)
            resultLabel.text = result
        } else {
            let alert = UIAlertController(title: "오류", message: "올바른 숫자를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
            amountTextField.text = .none
        }
    }
    
    // Caculator View 정보 설정
    func configure(rateItem: RateItem) {
        currencyLabel.text = rateItem.currencyCode
        countryLabel.text = rateItem.countryName
        print(rateItem.currencyCode, rateItem.countryName)
    }
}
