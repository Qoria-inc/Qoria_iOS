//
//  TokenRefresher.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

final class TokenRefresher {

    static let shared = TokenRefresher()
    private init() {}

    private let lock = NSLock()
    private var isRefreshing = false
    private var waiters: [(Result<String, Error>) -> Void] = []

    /// Uses the backend refresh endpoint and returns a new access token.
    func refreshAccessToken(session: Session) async throws -> String {

        // If already refreshing, wait
        try await withCheckedThrowingContinuation { cont in
            lock.lock()
            if isRefreshing {
                waiters.append { cont.resume(with: $0) }
                lock.unlock()
                return
            }
            isRefreshing = true
            waiters.append { cont.resume(with: $0) }
            lock.unlock()

            Task {
                do {
                    let newToken = try await self.performRefresh(session: session)
                    self.finish(.success(newToken))
                } catch {
                    self.finish(.failure(error))
                }
            }
        }
    }

    private func finish(_ result: Result<String, Error>) {
        lock.lock()
        isRefreshing = false
        let callbacks = waiters
        waiters.removeAll()
        lock.unlock()

        callbacks.forEach { $0(result) }
    }

    private func performRefresh(session: Session) async throws -> String {
        guard let refresh = AuthTokenStore.shared.refreshToken, !refresh.isEmpty else {
            throw NetworkError.unauthorized("Refresh token missing.")
        }
        
        let url = AppUrl.shared.refreshURL()
        let params: Parameters = ["refresh": refresh]
        
        let response = await session.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )
        .serializingData()
        .response
        
//        if let error = response.error {
//            let status = response.response?.statusCode ?? -1
//            throw NetworkError.httpStatus(status, response.data)
//        }
        
        guard let data = response.data else {
            throw NetworkError.emptyResponse
        }
        
        let json = try JSON(data: data)
        
        // Use "result" for both success and error
        let result = json["result"].string
        if result != "success" {
            let message = json["message"].string ?? "Token refresh failed."
            throw NetworkError.unauthorized(message)
        }
        
        guard let newAccess = json["data"]["access"].string else {
            throw NetworkError.invalidJSON
        }
        
        if let newRefresh = json["data"]["refresh"].string {
            AuthTokenStore.shared.refreshToken = newRefresh
        }
        
        AuthTokenStore.shared.accessToken = newAccess
        return newAccess
    }
}
