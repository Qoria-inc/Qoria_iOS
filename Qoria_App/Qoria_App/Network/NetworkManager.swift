//
//  NetworkManager.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation
import Alamofire

final class NetworkManager {

    static let shared = NetworkManager()

    private let session: Session

    private init() {
        let interceptor = AuthInterceptor()
        #if DEBUG
        let logger = NetworkLogger(level: .verbose)
        #else
        let logger = NetworkLogger(level: .basic)
        #endif

        session = Session(
            interceptor: interceptor,
            eventMonitors: [logger]
        )
    }

    func requestData(
        url: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        timeout: TimeInterval = 30
    ) async throws -> Data {

        let encoding: ParameterEncoding = {
            switch method {
            case .get, .head, .delete:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()

        let response = await session.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            requestModifier: { $0.timeoutInterval = timeout }
        )
        .validate()
        .serializingData()
        .response

        if let afError = response.error {
            if afError.isExplicitlyCancelledError {
                throw CancellationError()
            }
            let statusCode = response.response?.statusCode
            throw NetworkError.httpStatus(statusCode ?? -1, response.data)
        }

        guard let data = response.data else {
            throw NetworkError.emptyResponse
        }

        return data
    }

    func requestJSON(
        url: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        timeout: TimeInterval = 30
    ) async throws -> JSON {
        let data = try await requestData(url: url, method: method, parameters: parameters, headers: headers, timeout: timeout)
        return try JSON(data: data)
    }
}
