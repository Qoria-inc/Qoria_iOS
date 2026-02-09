//
//  QoriaAppBarView.swift
//  qoria_dev
//
//

import SwiftUI

struct QoriaAppBarView: View {
    var profileImage: Image? = Image("ic_proImg")
    var onProfileTap: (() -> Void)? = nil
    var onNotificationTap: (() -> Void)? = nil
    var onChatTap: (() -> Void)? = nil

    @State private var showProfileUnderDevelopment = false
    @State private var showNotificationUnderDevelopment = false
    @State private var showChatUnderDevelopment = false

    var body: some View {
        let outerSize: CGFloat = 46
        let innerProfileSize: CGFloat = 38

        ZStack {
            HStack(spacing: 8) {

                // MARK: - Profile
                Button {
                    showProfileUnderDevelopment = true
                    onProfileTap?()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            colors: [
                                                Color.Profile.borderWhiteBase.opacity(1),
                                                Color.Profile.borderBlueBase.opacity(0.5),
                                                Color.Profile.borderWhiteBase.opacity(1),
                                                Color.Profile.borderBlueBase.opacity(0.5),
                                                Color.Profile.borderWhiteBase.opacity(1)
                                            ],
                                            center: .center
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        Group {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Circle().fill(Color.Profile.ringInner)
                                Image(systemName: "person")
                                    .font(.system(size: innerProfileSize * 0.4))
                                    .foregroundStyle(Color.Text.onDark.opacity(0.7))
                            }
                        }
                        .frame(width: innerProfileSize, height: innerProfileSize)
                        .clipShape(Circle())
                    }
                    .frame(width: outerSize, height: outerSize)
                }
                .buttonStyle(.plain)

                Spacer()

                // MARK: - Action Icons
                HStack(spacing: 10) {

                    actionButton(
                        asset: "ic_notification",
                        size: outerSize
                    ) {
                        showNotificationUnderDevelopment = true
                        onNotificationTap?()
                    }

                    actionButton(
                        asset: "ic_chat",
                        size: outerSize
                    ) {
                        showChatUnderDevelopment = true
                        onChatTap?()
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            // MARK: - Title
            Image("ic_titelIcon")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 24)
        }
        .frame(height: 48)
        .background(Color.Surface.appBar)
        .alert("Under development", isPresented: $showProfileUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Profile screen is under development.")
        }
        .alert("Under development", isPresented: $showNotificationUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Notifications are under development.")
        }
        .alert("Under development", isPresented: $showChatUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Chat is under development.")
        }
    }

    // MARK: - Action Button (matches profile OUTER size)
    private func actionButton(
        asset: String,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {

        //let iconSize = min(size * 0.45, 24)

        let bubbleBorderGradient = LinearGradient(
            colors: [
                Color.Text.onDark.opacity(0.55),
                Color.Text.onDark.opacity(0.25),
                Color.Text.onDark.opacity(0.08),
                Color.black.opacity(0.2),
                Color.black.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        return Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.Surface.iconButton)

                Image(asset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                    .foregroundStyle(Color.Text.onDark)

                Circle()
                    .stroke(bubbleBorderGradient, lineWidth: 1)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        QoriaAppBarView()
        Spacer()
    }
    .background(Color.Surface.appBar)
}
