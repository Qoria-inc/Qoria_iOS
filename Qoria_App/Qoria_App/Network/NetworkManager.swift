//
//  NetworkManager.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func makeGenericAPIRequestWithoutModel(url: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (Result<Any, Error>) -> Void) {
        AF.request(url, method: method, parameters: parameters, headers: headers).response { response in
            switch response.result {
                case .success(let data):
                    completion(.success(data as Any))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func makeGenericAPIRequestWithModel<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(url, method: method, parameters: parameters, headers: headers).responseDecodable { (response: DataResponse<T, AFError>) in
            switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
