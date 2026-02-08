//
//  Device.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import SwiftUI

extension UIDevice {
    static var isIPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    static var isIPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
}
