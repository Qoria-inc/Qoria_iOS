//
//  Qoria_AppApp.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import SwiftUI

@main
struct Qoria_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


// Mark: - Important stuff
//After login succeeds, store tokens:
//let json = try await NetworkCall.shared.postLogin(...)
//AuthTokenStore.shared.accessToken = json.data.accessToken.string
//AuthTokenStore.shared.refreshToken = json.data.refreshToken.string
