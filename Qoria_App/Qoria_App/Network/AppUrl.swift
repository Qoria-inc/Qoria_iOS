//
//  AppUrl.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation

class AppUrl {
    
    static let shared = AppUrl()
    
    // base URL
    private let baseURL = "https://apple.com"
    
    // login URL
    public func loginURL() -> String {
        return baseURL + "ohohohoohoo"
    }
    
    // privacy policy URL
    public func privacyPolicyURL() -> String {
        return baseURL + ""
    }
    
    // terms and conditions URL
    public func termsAndConditionsURL() -> String {
        return baseURL + ""
    }
}
