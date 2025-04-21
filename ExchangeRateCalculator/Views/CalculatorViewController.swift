//
//  CalculatorViewController.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/16/25.
//

import UIKit
import SnapKit
import Combine

final class CalculatorViewController: UIViewController {
    
    let viewModel: CalculatorViewModel
    var cancellables = Set<AnyCancellable>()
    
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
        textField.addTarget(self, action: #selector(didTextFieldChanged(_:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var convertButton: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.backgroundColor = .systemGray
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
        bindViewModel()
        viewModel.configure()
    }
    
    // MARK: - Initializers
    init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
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
        
        guard
            let input = amountTextField.text,
            let validatedInput = validateInput(input)
        else {
            amountTextField.text = ""
            viewModel.textInput = ""
            resultLabel.text = ""
            viewModel.resultText = ""
            return
        }
        viewModel.setNewExchangeRate(validatedInput)
    }
    
    @objc func didTextFieldChanged(_ sender: UITextField) {
        viewModel.textInput = sender.text ?? ""
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        
        viewModel.isButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.convertButton.isEnabled = isEnabled
                self?.convertButton.backgroundColor = isEnabled ? .systemBlue : .lightGray
            }
            .store(in: &cancellables)
        
        // Caculator View 정보 설정
        viewModel.$resultText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: resultLabel)
            .store(in: &cancellables)
        
        viewModel.$currencyLabelText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: currencyLabel)
            .store(in: &cancellables)
        
        viewModel.$countryLabelText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: countryLabel)
            .store(in: &cancellables)
        
        // 상태에 따라 Alert 표시
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    break
                case .loaded(_):
                    break
                case .error:
                    self.showAlert(alertTitle: "오류", message: "데이터를 불러올 수 없습니다", actionTitle: "확인")
                }
            }.store(in: &cancellables)
    }
    
    private func validateInput(_ text: String) -> Double? {
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let trimmedText = Double(trimmedText) else {
            self.showAlert(alertTitle: "오류", message: "올바른 숫자를 입력해주세요", actionTitle: "확인")
            return nil
        }
        
        return trimmedText
    }
    
    /// TapGesture 추가, tapGesture.cancelsTouchesInView = false로 뷰 내 터치 정상적으로 동작
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}
