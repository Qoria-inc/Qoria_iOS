//
//  LearnThisButtonView.swift
//  Qoria_App
//
//  CTA shown under a feed image/video: "Learn This".
//

import SwiftUI

struct LearnThisButtonView: View {

    // MARK: - Constants

    static let height: CGFloat = 40

    // MARK: - Properties

    var onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("Learn This")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.Text.onDark)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.Text.onDark)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
            .background(
                LinearGradient(
                    colors: [
                        Color.Gradient.learnThisStart.opacity(0.40),
                        Color.Gradient.proEnd.opacity(0.30)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.Surface.post
        VStack(spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.25))
                .frame(height: 240)
            LearnThisButtonView(onTap: {})
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

