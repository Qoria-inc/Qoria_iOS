//
//  AppColor.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 08/02/2026.
//

import SwiftUI

extension Color {

    // MARK: - App Surface & Background
    enum Surface {
        /// App bar background #17171A
        static let appBar = Color(red: 0x17/255, green: 0x17/255, blue: 0x1A/255)

        /// Post / card background #232328
        static let post = Color(red: 0x23/255, green: 0x23/255, blue: 0x28/255)

        /// Icon / button background #232328
        static let iconButton = Color(red: 0x23/255, green: 0x23/255, blue: 0x28/255)

        /// Slightly lighter grey (placeholders) #383838
        static let placeholder = Color(red: 0x38/255, green: 0x38/255, blue: 0x38/255)
    }

    // MARK: - Text
    enum Text {
        /// Primary content on dark background
        static let onDark = Color.white

        /// Secondary text on dark #B0B0B5
        static let secondary = Color(red: 0xB0/255, green: 0xB0/255, blue: 0xB5/255)
    }

    // MARK: - Profile & Avatars
    enum Profile {
        /// Avatar ring inner #E0E0E0
        static let ringInner = Color(red: 0xE0/255, green: 0xE0/255, blue: 0xE0/255)

        /// Avatar ring outer #BDBDBD
        static let ringOuter = Color(red: 0xBD/255, green: 0xBD/255, blue: 0xBD/255)

        /// App bar profile border blue base #D1E1FF
        static let borderBlueBase = Color(red: 0xD1/255, green: 0xE1/255, blue: 0xFF/255)

        /// App bar profile border white base
        static let borderWhiteBase = Color.white
    }

    // MARK: - Tags & Badges
    enum Tag {
        /// Teacher / tag fallback teal #2AB5AD
        static let teal = Color(red: 0x2A/255, green: 0xB5/255, blue: 0xAD/255)
    }

    enum Badge {
        /// PRO purple accent #582EA5
        static let purple = Color(red: 0x58/255, green: 0x2E/255, blue: 0xA5/255)
    }

    // MARK: - Premium
    enum Premium {
        /// Crown tag background (dark grey, rounded tag behind crown icon)
        static let crownTagBackground = Color(red: 0x2C/255, green: 0x2C/255, blue: 0x30/255)
    }

    // MARK: - Content Type Border (FeedContentTypeView)
    enum ContentTypeBorder {
        /// Medal: 50% #D14742, 50% #790166
        static let medalLeft  = Color(red: 0xD1/255, green: 0x47/255, blue: 0x42/255)
        static let medalRight = Color(red: 0x79/255, green: 0x01/255, blue: 0x66/255)
        /// Trophy: #FFE500 at 10% and 50% opacity
        static let trophy = Color(red: 0xFF/255, green: 0xE5/255, blue: 0x00/255)
        /// Crown: white at 10% and 50% opacity
        static let crown = Color.white
    }

    // MARK: - Gradients (colors only)
    enum Gradient {
        // Premium banner
        static let bannerLeft   = Color(red: 0x1B/255, green: 0x8D/255, blue: 0xB1/255)
        static let bannerMiddle = Color(red: 0x27/255, green: 0x2E/255, blue: 0xA5/255)
        static let bannerRight  = Color(red: 0x70/255, green: 0x05/255, blue: 0x6E/255)

        // User tag
        static let tagLeft  = Color(UIColor(red: 68/255, green: 102/255, blue: 147/255, alpha: 1))
        static let tagRight = Color(UIColor(red: 73/255, green: 136/255, blue: 146/255, alpha: 1))

        // PRO badge
        static let proStart = Color(red: 0x29/255, green: 0x2B/255, blue: 0xA5/255)
        static let proEnd   = Color(red: 0x10/255, green: 0xB0/255, blue: 0xB4/255)
    }
}
