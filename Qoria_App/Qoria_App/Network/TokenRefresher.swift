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

    /// Replace with your real refresh endpoint + parsing
    /// Returns new access token
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

        // Example refresh call; replace URL + params to match your backend
        let url = AppUrl.shared.refreshURL()
        let params: Parameters = ["refreshToken": refresh]

        let response = await session.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .serializingData()
            .response

        if response.error != nil {
            let status = response.response?.statusCode
            throw NetworkError.httpStatus(status ?? -1, response.data)
        }

        guard let data = response.data else { throw NetworkError.emptyResponse }
        let json = try JSON(data: data)

        // Adjust these keys to match your API
        guard let newAccess =
                json["data"]["accessToken"].string
             ?? json["accessToken"].string
        else {
            throw NetworkError.invalidJSON
        }

        // If backend also returns a new refresh token, store it
        if let newRefresh =
                json["data"]["refreshToken"].string
             ?? json["refreshToken"].string
        {
            AuthTokenStore.shared.refreshToken = newRefresh
        }

        AuthTokenStore.shared.accessToken = newAccess
        return newAccess
    }
}
