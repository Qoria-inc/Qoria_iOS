//
//  AppUrl.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation

final class AppUrl {

    static let shared = AppUrl()
    private init() {}

    // Example base
    private let baseURL = "https://apple.com"
    
    public func refreshURL() -> String {
        return baseURL + "/auth/refresh"
    }

    public func loginURL() -> String {
        // TODO: Replace with your real API
        return baseURL + "/ohohohoohoo"
    }

    // Quick test endpoint that returns JSON
    public func testTodoURL() -> String {
        return "https://jsonplaceholder.typicode.com/todos/1"
    }

    public func privacyPolicyURL() -> String { baseURL + "/privacy" }
    public func termsAndConditionsURL() -> String { baseURL + "/terms" }
}

