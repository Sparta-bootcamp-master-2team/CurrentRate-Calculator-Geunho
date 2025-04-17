//
//  NetworkManager.swift
//  ExchangeRateCalculator
//
//  Created by 정근호 on 4/17/25.
//

import Foundation
import Alamofire

enum DataError: Error {
    case decodingFailed
    case invalidURL
    case serverError(code: Int)
    case unknown
}

final class NetworkManager {
    
    static let shared = NetworkManager() // 전역에서 공유되는 인스턴스
    
    private init() {} // 외부에서 생성 못하게 막음
    
    func fetchData<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: "https://open.er-api.com/v6/latest/USD") else {
            completion(.failure(DataError.invalidURL))
            return
        }
        
        AF.request(url)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let afError):
                    if let statusCode = response.response?.statusCode {
                        completion(.failure(DataError.serverError(code: statusCode)))
                    } else if afError.isResponseSerializationError {
                        completion(.failure(DataError.decodingFailed))
                    } else {
                        completion(.failure(DataError.unknown))
                    }
                }
            }
    }
    
}
