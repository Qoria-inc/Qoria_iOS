//
//  AuthInterceptor.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {

    private let store = AuthTokenStore.shared

    // Add token to outgoing request
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {

        var req = urlRequest

        // Don't add Authorization header for refresh token requests
        // The refresh endpoint only needs the refresh token in the body
        if let urlString = req.url?.absoluteString,
           urlString.contains("/api/auth/token/refresh/") {
            completion(.success(req))
            return
        }

        if let token = store.accessToken, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        completion(.success(req))
    }

    // Retry on 401 once refresh succeeds
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        // Don't retry refresh token requests - they should fail if invalid
        if let urlString = request.request?.url?.absoluteString,
           urlString.contains("/api/auth/token/refresh/") {
            completion(.doNotRetry)
            return
        }

        // No response? don't retry.
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }

        // Only handle 401
        guard statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        // Prevent infinite loop: if we already retried this request, stop.
        // Alamofire increments retryCount on the Request.
        if request.retryCount >= 1 {
            completion(.doNotRetry)
            return
        }

        Task {
            do {
                _ = try await TokenRefresher.shared.refreshAccessToken(session: session)
                completion(.retry)
            } catch {
                // Refresh failed → tokens invalid → logout
                await AuthTokenStore.shared.clear()
                completion(.doNotRetry)
            }
        }
    }
}
