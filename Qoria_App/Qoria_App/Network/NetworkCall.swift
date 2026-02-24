//
//  NetworkCall.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

protocol NetworkCalling {
    //func postLogin(username: String, password: String) async throws -> JSON
    func loginWithEmail() async throws -> JSON
}

final class NetworkCall: NetworkCalling {

    static let shared = NetworkCall()
    private init() {}

    // MARK: - LOGIN WITH EMAIL (hardcoded for now)
    func loginWithEmail() async throws -> JSON {
        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        let parameters: Parameters = [
            "email": "umairkmehmood789+7@gmail.com",
            "password": "password123"
        ]

        return try await NetworkManager.shared.requestJSON(
            url: AppUrl.shared.loginWithEmailURL(),
            method: .post,
            parameters: parameters,
            headers: headers
        )
    }

}
