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

    // base url staging
    private let baseURL = "https://staging.api.qoria.app"
    
    // base url production
    // private let baseURL = ""
    
    public func refreshURL() -> String {
        return baseURL + "/api/auth/token/refresh/"
    }

    public func loginWithEmailURL() -> String {
        return baseURL + "/api/auth/login/"
    }

    public func homeFeedURL() -> String {
        return baseURL + "/api/post/feed/"
    }

    public func privacyPolicyURL() -> String { baseURL + "/privacy" }
    public func termsAndConditionsURL() -> String { baseURL + "/terms" }
}

