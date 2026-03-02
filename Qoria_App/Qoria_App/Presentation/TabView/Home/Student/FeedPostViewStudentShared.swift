//
//  FeedPostViewStudentShared.swift
//  Qoria_App
//
//  Student feed post view for "share" posts:
//  - Outer post is the student user post
//  - Inside it, a shared post preview is shown in a bordered container
//

import SwiftUI

struct FeedPostViewStudentShared: View {

    // MARK: - State

    @State private var showUnderDevelopment = false

    let sharedUserName: String
    let sharedUserTypeLabel: String
    let sharedTimeLabel: String
    let sharedText: String

    let innerPost: AnyView

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView

            Text(sharedText)
                .font(.body)
                .foregroundStyle(Color.Text.onDark)
                .fixedSize(horizontal: false, vertical: true)

            // Shared post container – height purely driven by inner post
            innerPost
                .clipShape(RoundedRectangle(cornerRadius: 12))   // inner post 12pt corner radius
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.Surface.iconButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.Text.onDark.opacity(0.12), lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .clipped()
        .background(Color.Surface.post)
        .alert("Under development", isPresented: $showUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This feature is under development.")
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 52, height: 52)

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
                        .frame(width: 52, height: 52)

                    Image("ic_proImg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sarah Morgan")
                        .font(.system(size: 16, weight: .medium))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.Text.onDark)

                    HStack(spacing: 8) {
                        Text("3d ago")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.Text.secondary)

                        HStack(spacing: 6) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Shared inside Qoria")
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(Color.Text.secondary)
                    }
                }
            }

            Spacer()

            Button {
                showUnderDevelopment = true
            } label: {
                Image("ic_more")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FeedPostViewStudentShared(
            sharedUserName: "Daniel Reyes",
            sharedUserTypeLabel: "Teacher/Artist",
            sharedTimeLabel: "1w ago",
            sharedText: "Exploring trust and balance through simple partner movements.",
            innerPost: AnyView(
                FeedPostViewTeacherAndArtist(
                    image: "ic_postImg2",
                    showsLearnThis: false,
                    competitionStatusTitle: nil,
                    competitionCurrentStatusTitle: nil,
                    isEmbedded: true
                )
            )
        )
        .padding(.top, 16)
        .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}

