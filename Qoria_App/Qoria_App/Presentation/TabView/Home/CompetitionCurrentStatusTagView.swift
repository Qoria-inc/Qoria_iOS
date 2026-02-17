//
//  CompetitionCurrentStatusTagView.swift
//  Qoria_App
//
//  Small status pill shown under the title:
//  - Winners Announced (yellow)
//  - Voting ends in 4h (green)
//  - Vote is over / Reaction to the winners (neutral)
//

import SwiftUI

struct CompetitionCurrentStatusTagView: View {

    enum Style {
        case winnersAnnounced
        case votingEndsSoon
        case neutral
    }

    let title: String
    let style: Style

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(foregroundColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(backgroundColor)
        )
        .overlay(
            Capsule()
                .stroke(borderGradient, lineWidth: 0.5)
        )
        .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
    }

    private var backgroundColor: Color {
        switch style {
        case .winnersAnnounced:
            // #FDB022 at 10%
            return Color.Competition.winnersYellow.opacity(0.10)
        case .votingEndsSoon:
            // #17B26A at 5%
            return Color.Competition.votingGreenBg.opacity(0.05)
        case .neutral:
            return Color.white.opacity(0.10)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .winnersAnnounced:
            // #FDB022
            return Color.Competition.winnersYellow
        case .votingEndsSoon:
            // #47CD89
            return Color.Competition.votingGreen
        case .neutral:
            return Color.white.opacity(0.9)
        }
    }

    private var dotColor: Color {
        switch style {
        case .winnersAnnounced:
            // #FDB022
            return Color.Competition.winnersYellow
        case .votingEndsSoon:
            // #47CD89
            return Color.Competition.votingGreen
        case .neutral:
            return Color.white.opacity(0.8)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .winnersAnnounced:
            // Shadow in label color
            return Color.Competition.winnersYellow.opacity(0.55)
        case .votingEndsSoon:
            return Color.Competition.votingGreen.opacity(0.55)
        case .neutral:
            return Color.white.opacity(0.25)
        }
    }

    // MARK: - Border Gradient (matches app bar notification button)
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.Text.onDark.opacity(0.4),
                Color.Text.onDark.opacity(0.2),
                Color.Text.onDark.opacity(0.08),
                Color.Text.onDark.opacity(0.2),
                Color.Text.onDark.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        CompetitionCurrentStatusTagView(
            title: "Winners Announced",
            style: .winnersAnnounced
        )
        CompetitionCurrentStatusTagView(
            title: "Voting ends in 4h",
            style: .votingEndsSoon
        )
        CompetitionCurrentStatusTagView(
            title: "Voting is over",
            style: .neutral
        )
    }
    .padding()
    .background(Color.Surface.post)
    .preferredColorScheme(.dark)
}

