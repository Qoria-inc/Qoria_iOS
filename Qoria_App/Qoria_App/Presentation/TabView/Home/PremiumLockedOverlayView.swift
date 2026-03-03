//
//  PremiumLockedOverlayView.swift
//  Qoria_App
//
//  Created by Sharif Rafi on 3/3/26.
//

import Foundation
import SwiftUI

// MARK: - Premium Locked Overlay

struct PremiumLockedOverlayView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.15))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()

                VStack(spacing: 18) {
                    Image("ic_lockForPremium")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 90)

                    Text("This is premium content. Up to 10 posts per month are free – follow premium for unlimited access.")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.Text.onDark)
                        .padding(.horizontal, 24)

                    VStack(spacing: 10) {
                        Button(action: {
                            print("View Post Tapped")
                        }) {
                            Text("View Post")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: UIScreen.screenWidth * 0.7, height: 44)
                        }
                        .foregroundStyle(Color.black)
                        .background(Color.white.opacity(0.9), in: Capsule())
                        .buttonStyle(.plain)

                        Button(action: {
                            print("Follow Premium Content Tapped")
                        }) {
                            Text("Follow Premium Content")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: UIScreen.screenWidth * 0.7, height: 44)
                        }
                        .foregroundStyle(Color.white)
                        .background(Color.white.opacity(0.08), in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }

            // badge with count
            HStack(spacing: 4) {
                Image(systemName: "lock.open.fill")
                    .padding(.trailing, 1)
                Text("0/10")
            }
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
            )
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
