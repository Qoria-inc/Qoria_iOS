//
//  FeedContentTypeView.swift
//  Qoria_App
//
//  Content type badge shown to the right of user type tag.
//  Displays one of: medal, single trophy, count trophy, or crown based on flags.
//  Exactly one flag should be true at a time.
//

import SwiftUI

struct FeedContentTypeView: View {

    // MARK: - Properties

    /// Shows medal asset (ic_medalWithBG)
    var isMedal: Bool = false

    /// Shows single trophy asset (ic_singleTrophyWithBG)
    var isSingleTrophy: Bool = false

    /// Shows count trophy asset (ic_trophyWithBG)
    var isCountTrophy: Bool = false

    /// Shows crown asset (ic_crownWithBG)
    var isCrown: Bool = false
    
    /// Shows lock asset (ic_lockWithBG)
    var isLock: Bool = false

    // MARK: - Computed Properties

    private var assetName: String? {
        if isMedal { return "ic_medalWithBG" }
        if isSingleTrophy { return "ic_singleTrophyWithBG" }
        if isCountTrophy { return "ic_trophyWithBG" }
        if isCrown { return "ic_crownWithBG" }
        if isLock { return "ic_lockWithBG" }
        return nil
    }

    /// Border gradient by content type: medal 50–50%, trophy/crown 10%–50% opacity.
    private var borderGradient: LinearGradient {
        if isMedal {
            return LinearGradient(
                colors: [Color.ContentTypeBorder.medalLeft, Color.ContentTypeBorder.medalRight],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        if isSingleTrophy || isCountTrophy {
            return LinearGradient(
                colors: [
                    Color.ContentTypeBorder.trophy.opacity(0.10),
                    Color.ContentTypeBorder.trophy.opacity(0.50)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        if isCrown {
            return LinearGradient(
                colors: [
                    Color.ContentTypeBorder.crown.opacity(0.10),
                    Color.ContentTypeBorder.crown.opacity(0.50)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        if isLock {
            return LinearGradient(
                colors: [
                    Color.ContentTypeBorder.lock.opacity(0.55),
                    Color.ContentTypeBorder.lock.opacity(0.25),
                    Color.ContentTypeBorder.lock.opacity(0.08),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
    }

    // MARK: - Body

    /// User type tag height: font 12 + vertical padding 4×2 (matches Teacher/Artist/Student tag).
    private static let userTypeTagHeight: CGFloat = 20
    /// Width:height ratio same as PremiumCrownTag (28:20).
    private static let contentTypeTagRatio: CGFloat = 28 / 20

    private static var contentTypeTagHeight: CGFloat { userTypeTagHeight }
    private static var contentTypeTagWidth: CGFloat { userTypeTagHeight * contentTypeTagRatio }

    var body: some View {
        if let assetName = assetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: Self.contentTypeTagWidth, height: Self.contentTypeTagHeight)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(borderGradient, lineWidth: 0.5)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.Surface.post
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Text("Teacher")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Gradient.tagLeft, Color.Gradient.tagRight], startPoint: .leading, endPoint: .trailing), in: Capsule())
                FeedContentTypeView(isMedal: true)
            }

            HStack(spacing: 6) {
                Text("Artist")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Gradient.tagLeft, Color.Gradient.tagRight], startPoint: .leading, endPoint: .trailing), in: Capsule())
                FeedContentTypeView(isSingleTrophy: true)
            }

            HStack(spacing: 6) {
                Text("Student")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Gradient.tagLeft, Color.Gradient.tagRight], startPoint: .leading, endPoint: .trailing), in: Capsule())
                FeedContentTypeView(isCountTrophy: true)
            }

            HStack(spacing: 6) {
                Text("Premium")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Gradient.tagLeft, Color.Gradient.tagRight], startPoint: .leading, endPoint: .trailing), in: Capsule())
                FeedContentTypeView(isCrown: true)
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
