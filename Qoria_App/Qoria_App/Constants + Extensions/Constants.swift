//
//  Constants.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import Foundation

// Unsaved Constants - Data not stored on Disk.
struct Constants {
    static var demoConstant: String = "Demo"
}

// Saved Constants - Data stored on the Disk
struct SavedData {
    static var appLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appLanguage")
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        }
    }
}
