//
//  PremiumCrownTag.swift
//  Qoria_App
//
//  Premium crown tag shown to the right of user type tag when account is premium.
//  By default shows as premium; later isPremium can be driven from API.
//

import SwiftUI

struct PremiumCrownTag: View {

    /// When false, view renders empty. Default true for current UI; switch to API later.
    var isPremium: Bool = true

    // MARK: - Body

    var body: some View {
        if isPremium {
            Image(systemName: "crown.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.Text.onDark)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.Premium.crownTagBackground)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            AngularGradient(
                                colors: [.white, .white, Color.Gradient.tagRight, .white],
                                center: .center
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    ZStack {
        Color.Surface.post
        HStack(spacing: 6) {
            Text("Teacher")
                .font(.system(size: 12))
                .foregroundStyle(Color.Text.onDark)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(LinearGradient(colors: [Color.Gradient.tagLeft, Color.Gradient.tagRight], startPoint: .leading, endPoint: .trailing), in: Capsule())
            PremiumCrownTag()
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
