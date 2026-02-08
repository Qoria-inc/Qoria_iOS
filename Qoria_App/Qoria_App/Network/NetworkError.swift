//
//  NetworkError.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {

    case emptyResponse
    case invalidJSON
    case unauthorized(String?)
    case httpStatus(Int, Data?)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Empty response from server."

        case .invalidJSON:
            return "Response is not valid JSON."

        case .unauthorized(let message):
            return message ?? "Unauthorized."

        case .httpStatus(let code, let data):
            if let data,
               let text = String(data: data, encoding: .utf8),
               !text.isEmpty {
                return "HTTP \(code): \(text)"
            }
            return "HTTP error with status code \(code)."
        }
    }
}
