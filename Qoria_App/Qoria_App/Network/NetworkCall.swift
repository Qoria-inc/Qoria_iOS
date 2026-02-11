//
//  NetworkCall.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

protocol NetworkCalling {
    func postLogin(username: String, password: String) async throws -> JSON
    func getTestTodo() async throws -> JSON
}

final class NetworkCall: NetworkCalling {

    static let shared = NetworkCall()
    private init() {}

    // MARK: - LOGIN (dynamic JSON)
    func postLogin(username: String, password: String) async throws -> JSON {
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let parameters: Parameters = [
            "login": username,
            "password": password
        ]

        return try await NetworkManager.shared.requestJSON(
            url: AppUrl.shared.loginURL(),
            method: .post,
            parameters: parameters,
            headers: headers
        )
    }

    // MARK: - TEST GET (useful for quick UI test)
    func getTestTodo() async throws -> JSON {
        try await NetworkManager.shared.requestJSON(
            url: AppUrl.shared.testTodoURL(),
            method: .get
        )
    }
}
