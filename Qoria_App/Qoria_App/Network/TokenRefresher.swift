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
        
        // Validate HTTP status code first
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.httpStatus(-1, response.data)
        }
        
        guard (200...299).contains(statusCode) else {
            throw NetworkError.httpStatus(statusCode, response.data)
        }
        
        guard let data = response.data else {
            throw NetworkError.emptyResponse
        }
        
        let json = try JSON(data: data)
        
        // Handle both possible response formats:
        // 1. { "result": "success", "data": { "access": "...", "refresh": "..." } }
        // 2. { "access": "...", "refresh": "..." } (direct format)
        
        let newAccess: String?
        let newRefresh: String?
        
        if let result = json["result"].string, result == "success" {
            // Format 1: nested in data
            newAccess = json["data"]["access"].string
            newRefresh = json["data"]["refresh"].string
        } else {
            // Format 2: direct access
            newAccess = json["access"].string
            newRefresh = json["refresh"].string
        }
        
        guard let accessToken = newAccess else {
            throw NetworkError.invalidJSON
        }
        
        // Update tokens
        AuthTokenStore.shared.accessToken = accessToken
        if let refreshToken = newRefresh {
            AuthTokenStore.shared.refreshToken = refreshToken
        }
        
        return accessToken
    }
}
