//
//  RatesCell.swift
//  CurrentRateCalculator
//
//  Created by 정근호 on 4/15/25.
//

import UIKit

class ExchangeRateCell: UITableViewCell {
    
    var rateItem = [RateItem]()
    
    static let id = "ExchangeRateCell"
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.text = "KRW"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "1400"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        contentView.backgroundColor = .systemBackground
        
        [countryLabel, priceLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setLayout() {
        countryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func configureCell(rateItem: RateItem) {
        countryLabel.text = rateItem.currencyCode
        priceLabel.text = String(format: "%.4f", rateItem.value)
    }
    

    
   
}
