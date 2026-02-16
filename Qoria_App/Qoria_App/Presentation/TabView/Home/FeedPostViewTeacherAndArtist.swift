//
//  FeedPostViewTeacherAndArtist.swift
//  Qoria_App
//
//  Feed post content view for Teacher/Artist user type. Layout identical to Teacher (FeedPostView).
//

import SwiftUI

struct FeedPostViewTeacherAndArtist: View {

    // MARK: - State

    @State private var showUnderDevelopment = false
    var image: String?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    ZStack(alignment: .bottomTrailing) {

                        ZStack {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 52, height: 52)

                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.Profile.teacherArtistPurple.opacity(0.60),
                                            Color.Gradient.proStart.opacity(0.50)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
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

                        Image("ic_proBadgePurple")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 26)
                            .offset(x: 3, y: 2)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading) {
                        HStack(spacing: 6) {
                            Text("Sarah Morgan")
                                .font(.system(size: 16, weight: .medium))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.Text.onDark)

                            Text("Teacher/Artist")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.Text.onDark)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.Profile.teacherArtistPurple.opacity(0.40),
                                            Color.Gradient.proStart.opacity(0.30)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule().stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.Profile.teacherArtistPurple.opacity(0.40),
                                                Color.Gradient.proStart.opacity(0.30)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 0.5
                                    )
                                )

                            FeedContentTypeView(isCrown: true)
                        }

                        Text("2h ago")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.Text.secondary)
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

            Text("Exploring trust and balance through simple partner movements.")
                .font(.body)
                .foregroundStyle(Color.Text.onDark)
                .fixedSize(horizontal: false, vertical: true)

            Image(image ?? "ic_postImg1")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, alignment: .center)
                .clipped()
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showUnderDevelopment = true
                    } label: {
                        Image("ic_volumeWithBG")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, -16)

            HStack(spacing: 20) {

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_clap")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text("128")
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_comment")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("24")
                            .font(.system(size: 14))
                            .padding(.leading, 5)
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("9")
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Button { showUnderDevelopment = true } label: {
                    Image("ic_save")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)
            }
            .font(.system(size: 14))
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .clipped()
        .background(Color.Surface.post)
        .alert("Under development", isPresented: $showUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This feature is under development.")
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FeedPostViewTeacherAndArtist(image: "ic_postImg1")
            .padding(.top, 16)
            .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}
