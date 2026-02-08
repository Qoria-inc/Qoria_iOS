//
//  AuthTokenStore.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation

final class AuthTokenStore {
    static let shared = AuthTokenStore()
    private init() {}

    private let accessKey = "auth.accessToken"
    private let refreshKey = "auth.refreshToken"

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessKey) }
        set {
            if let newValue { UserDefaults.standard.set(newValue, forKey: accessKey) }
            else { UserDefaults.standard.removeObject(forKey: accessKey) }
        }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshKey) }
        set {
            if let newValue { UserDefaults.standard.set(newValue, forKey: refreshKey) }
            else { UserDefaults.standard.removeObject(forKey: refreshKey) }
        }
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
    }
}
