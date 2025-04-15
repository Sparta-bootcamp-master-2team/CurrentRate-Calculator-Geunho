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

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCell.id) as? ExchangeRateCell else {
            return UITableViewCell()
        }
        return cell
    }
}
