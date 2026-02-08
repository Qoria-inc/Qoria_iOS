//
//  NetworkCall.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

class NetworkCall {
    
    static let shared = NetworkCall()
    
    // ----------------------------------------------------------------------------- //
    // AUTH BEGIN
    // ----------------------------------------------------------------------------- //
    
    // MARK: - LOGIN
    func postLogin(username: String, password: String, completion: @escaping (Data?) -> ()) {
        
        let headers = ["Content-Type": "application/json", "Token": "Bearer "] as HTTPHeaders
        
        let parameters = ["login": username as AnyObject, "password": password as AnyObject]
        
        NetworkManager.shared.makeGenericAPIRequestWithoutModel(url: AppUrl.shared.loginURL(), method: .post, parameters: parameters, headers: headers) { result in
            switch result {
                case .success(let value):
                    if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                        completion(jsonData)
                    }
                case .failure(let error):
                    print("API request failed: \(error)")
            }
        }
    }
    
    // ----------------------------------------------------------------------------- //
    // AUTH END
    // ----------------------------------------------------------------------------- //
}
