//
//  CompetitionStatusButtonView.swift
//  Qoria_App
//
//  Bottom-of-image competition CTA:
//  - Winners Pending
//  - See Winners
//  - See the Competition
//

import SwiftUI

struct CompetitionStatusButtonView: View {

    // MARK: - Constants

    /// Match visual height of volume button (32 icon)
    static let height: CGFloat = 32

    let title: String
    var onTap: () -> Void = {}

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image("ic_trophy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.Text.onDark)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .frame(height: Self.height)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.Gradient.competitionStart.opacity(0.50),
                                Color.Gradient.competitionEnd.opacity(0.50)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.Text.onDark.opacity(0.45),
                                Color.Text.onDark.opacity(0.25),
                                Color.Text.onDark.opacity(0.08),
                                Color.Text.onDark.opacity(0.25),
                                Color.Text.onDark.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.Competition.glow.opacity(0.18),
                radius: 16,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.Surface.post

        VStack {
            Spacer()
            CompetitionStatusButtonView(title: "See Winners")
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

