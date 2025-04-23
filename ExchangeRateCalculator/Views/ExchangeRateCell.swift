//
//  RatesCell.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import UIKit
import Combine

final class ExchangeRateCell: UITableViewCell {
    
    private var viewModel: ExchangeRateCellViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    static var id: String {
        return String(describing: ExchangeRateCell.self)
    }
    
    // MARK: - UI Components
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currencyLabel, countryLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemYellow
        button.addTarget(self, action: #selector(favoriteButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI & Layout
    private func setUI() {
        contentView.backgroundColor = .systemBackground
        
        [labelStackView, rateLabel, iconImageView, favoriteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setLayout() {
        
        labelStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        rateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(iconImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(labelStackView.snp.trailing).offset(16)
            make.width.equalTo(120)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(rateLabel.snp.trailing).offset(8)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc func favoriteButtonClicked() {
        // 클릭 시 즐겨찾기 상태 설정
        viewModel?.setFavoriteStatus()
    }
    
    // MARK: - Internal Methods
    func bindViewModel(_ viewModel: ExchangeRateCellViewModel) {
        self.viewModel = viewModel
        
        currencyLabel.text = viewModel.rateItem.currencyCode
        rateLabel.text = String(format: "%.2f", viewModel.rateItem.value)
        
        switch viewModel.rateItem.change {
        case .up:
            iconImageView.image = UIImage(systemName: "arrow.up")
            iconImageView.tintColor = .systemRed
        case .down:
            iconImageView.image = UIImage(systemName: "arrow.down")
            iconImageView.tintColor = .systemBlue
        case .same:
            iconImageView.image = nil
        }
        
        currencyLabel.text = viewModel.rateItem.currencyCode
        rateLabel.text = viewModel.rateItem.value.toDigits(4)
        countryLabel.text = viewModel.rateItem.countryName

        viewModel.$isFavorite
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    let image = $0 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    self?.favoriteButton.setImage(image, for: .normal)
                }
                .store(in: &cancellables)
    }
}

