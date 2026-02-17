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
    var images: [String]? = nil
    var showsLearnThis: Bool = false
    var competitionStatusTitle: String? = nil
    var competitionCurrentStatusTitle: String? = nil
    /// When `true`, this view is rendered inside another container (e.g. shared post)
    /// and should not apply its own outer padding/background or show the top-right "more" button.
    var isEmbedded: Bool = false

    // MARK: - Computed Properties

    /// Returns media array: prefers `images` if provided, otherwise wraps single `image` in array.
    /// Currently supports up to 2 items (API can return 1 or 2).
    private var mediaItems: [String] {
        if let images, !images.isEmpty {
            return Array(images.prefix(2))
        } else if let image {
            return [image]
        } else {
            return ["ic_postImg1"]
        }
    }

    private var hasMultipleMedia: Bool {
        mediaItems.count == 2
    }

    // MARK: - Helpers

    private func styleForStatus(title: String) -> CompetitionCurrentStatusTagView.Style {
        if title.lowercased().contains("winners announced") {
            return .winnersAnnounced
        } else if title.lowercased().contains("voting ends") {
            return .votingEndsSoon
        } else {
            return .neutral
        }
    }

    // MARK: - Body

    var body: some View {
        content
            .alert("Under development", isPresented: $showUnderDevelopment) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This feature is under development.")
            }
    }

    @ViewBuilder
    private var content: some View {
        let core = VStack(alignment: .leading, spacing: 12) {
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

                    VStack(alignment: .leading, spacing: 4) {
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
                                            Color.Gradient.proStart.opacity(0.40),
                                            Color.Profile.teacherArtistPurple.opacity(0.50)
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

                if !isEmbedded {
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

            Text("Exploring trust and balance through simple partner movements.")
                .font(.body)
                .foregroundStyle(Color.Text.onDark)
                .fixedSize(horizontal: false, vertical: true)

            if let statusTitle = competitionCurrentStatusTitle {
                CompetitionCurrentStatusTagView(
                    title: statusTitle,
                    style: styleForStatus(title: statusTitle)
                )
                .padding(.top, -2)
            }

            VStack(spacing: 0) {
                mediaView

                if showsLearnThis {
                    LearnThisButtonView {
                        showUnderDevelopment = true
                    }
                    .padding(.horizontal, -16)
                }
            }

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

        core
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .clipped()
            .background(Color.Surface.post)
    }

    // MARK: - Media View

    @ViewBuilder
    private var mediaView: some View {
        let containerSize = UIScreen.main.bounds.width

        if hasMultipleMedia {
            ZStack {
                // Container BG #17171A
                Color.Surface.appBar

                HStack(spacing: 2) {
                    ForEach(Array(mediaItems.enumerated()), id: \.offset) { _, media in
                        Image(media)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: (containerSize - 6) / 2,     // 2px left + 2px right + 2px gap
                                height: containerSize - 4           // 2px top + 2px bottom
                            )
                            .clipped()
                            .cornerRadius(4)
                    }
                }
                .padding(2)
            }
            .frame(width: containerSize, height: containerSize)
            .overlay(alignment: .bottom) {
                ZStack {
                    if let title = competitionStatusTitle {
                        HStack {
                            Spacer()
                            CompetitionStatusButtonView(title: title) {
                                showUnderDevelopment = true
                            }
                            Spacer()
                        }
                    }

                    HStack {
                        Spacer()
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
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, -16)
        } else {
            Image(mediaItems.first ?? "ic_postImg1")
                .resizable()
                .scaledToFill()
                .frame(width: containerSize, height: containerSize, alignment: .center)
                .clipped()
                .overlay(alignment: .bottom) {
                    ZStack {
                        if let title = competitionStatusTitle {
                            HStack {
                                Spacer()
                                CompetitionStatusButtonView(title: title) {
                                    showUnderDevelopment = true
                                }
                                Spacer()
                            }
                        }

                        HStack {
                            Spacer()
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
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, -16)
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
