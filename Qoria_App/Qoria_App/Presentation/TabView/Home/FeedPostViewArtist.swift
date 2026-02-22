//
//  FeedPostViewArtist.swift
//  Qoria_App
//
//  Feed post content view for Artist user type. Layout identical to Teacher (FeedPostView).
//

import SwiftUI

struct FeedPostViewArtist: View {

    // MARK: - State
    @State private var showUnderDevelopment = false
    var image: String?
    var images: [String]? = nil
    var username: String?
    var postTitle: String?
    var statusTitle: String?
    var postTime: String?
    var reactCount: String?
    var commentCount: String?
    var shareCount: String? 

    // MARK: - Computed Properties
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
                                        colors: [Color.Profile.artistBorderLeft, Color.Profile.artistBorderRight],
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

                        Image("ic_proBadgeRed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 26)
                            .offset(x: 3, y: 2)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(self.username ?? "")
                                .font(.system(size: 16, weight: .medium))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.Text.onDark)

                            Text("Artist")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.Text.onDark)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.Profile.artistPurple.opacity(0.30),
                                            Color.Profile.artistRed.opacity(0.40)
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
                                                Color.Profile.artistRed.opacity(0.40),
                                                Color.Profile.artistPurple.opacity(0.30)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 0.5
                                    )
                                )

                            FeedContentTypeView(isCrown: true)
                        }

                        Text(self.postTime ?? "")
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

            Text(self.postTitle ?? "")
                .font(.body)
                .foregroundStyle(Color.Text.onDark)
                .fixedSize(horizontal: false, vertical: true)

            if let statusTitle = statusTitle {
                CompetitionCurrentStatusTagView(
                    title: statusTitle,
                    style: styleForStatus(title: statusTitle)
                )
                .padding(.top, -2)
            }

            VStack(spacing: 0) {
                mediaView
            }

            HStack(spacing: 20) {

                Button { showUnderDevelopment = true } label: {
                    HStack(spacing: 4) {
                        Image("ic_clap")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text(self.reactCount ?? "")
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
                        Text(self.commentCount ?? "")
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
                        Text(self.shareCount ?? "")
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

    // MARK: - Media View

    @ViewBuilder
    private var mediaView: some View {
        let containerSize = UIScreen.main.bounds.width

        if hasMultipleMedia {
            ZStack {
                // Container BG #17171A
                Color.Surface.appBackground

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
                    if let title = postTitle {
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
            //FeedMediaImage(source: mediaItems.first ?? "ic_postImg1")
            Image("ic_postImg1")
                .resizable()
                .scaledToFill()
                .frame(width: containerSize, height: containerSize, alignment: .center)
                .clipped()
                .overlay(alignment: .bottom) {
                    ZStack {
                        if let title = postTitle {
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
        FeedPostViewArtist(image: "ic_postImg1")
            .padding(.top, 16)
            .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}
