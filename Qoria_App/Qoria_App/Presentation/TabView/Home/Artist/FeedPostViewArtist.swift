//
//  FeedPostViewArtist.swift
//  Qoria_App
//
//  Feed post content view for Artist user type. Layout identical to Teacher (FeedPostView).
//

import SwiftUI
import AVFoundation
import AVKit

struct FeedPostViewArtist: View {
    
    // MARK: Inputs
    var focusedMediaPostIndex: Int? = nil
    var postIndex: Int = 0

    var json: dynamicJSON = dynamicJSON()
    var showsPremiumOverlay: Bool = false

    // MARK: Body

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .clipped()
            .background(Color.Surface.post)
    }
}

// MARK: - FeedPostViewArtist Layout

private extension FeedPostViewArtist {
    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            captionSection
            currentCompetitionStatusSection
            mediaSection
            actionsSection
        }
    }

    var headerSection: some View {
        HStack {
            HStack {
                profileImageSection
                profileMetaSection
            }

            Spacer()

            moreButton
        }
    }

    var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 52, height: 52)

                Circle()
                    .stroke(
                        LinearGradient(colors: [Color.Profile.artistBorderLeft, Color.Profile.artistBorderRight], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    .frame(width: 52, height: 52)

                FeedMediaImage(source: json.owner_info.avatar.string ?? "")
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
    }

    var profileMetaSection: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                Text(json.owner_info.name.string ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.Text.onDark)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("Artist")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Profile.artistPurple.opacity(0.30),
                                                        Color.Profile.artistRed.opacity(0.40)], startPoint: .leading, endPoint: .trailing), in: Capsule())
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
                            lineWidth: 0.5))

                FeedContentTypeView(isSingleTrophy: json.post_type.int == 1
                                    ? true : false,
                                    isLock: json.post_type.int == 5 ? true : false)
            }  //TODO: Artist post type checking and setup - Falcon

            Text(FeedPostDateHelpers.createdAtDisplayText(from: json.created_at.string ?? ""))
                .font(.system(size: 14))
                .foregroundStyle(Color.Text.secondary)
        }
    }

    var moreButton: some View {
        Button {} label: {
            Image("ic_more")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }

    var captionSection: some View {
        Text(json.title.string ?? "")
            .font(.body)
            .foregroundStyle(Color.Text.onDark)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var currentCompetitionStatusSection: some View {
        if let statusTitle = json.challenge_current_status_title.string,
           statusTitle.isEmpty == false {
            CompetitionCurrentStatusTagView(
                title: statusTitle,
                style: FeedPostCompetitionStatusHelpers.styleForStatus(title: statusTitle)
            )
            .padding(.top, -2)
        }
    }

    var mediaSection: some View {
        VStack(spacing: 0) {
            FeedPostMediaView(
                media: FeedPostMediaKind.from(json),
                competitionStatusTitle: json.challenge_status_title.string,
                isInCenter: focusedMediaPostIndex == postIndex,
                showsPremiumOverlay: showsPremiumOverlay
            )
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: MediaFramesPreferenceKey.self, value: [postIndex: geo.frame(in: .global)])
                }
            )
        }
    }

    var actionsSection: some View {
        HStack(spacing: 20) {
            Button {} label: {
                HStack(spacing: 4) {
                    Image("ic_clap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("\(json.like_count.int ?? 0)")
                        .font(.system(size: 14))
                }
            }
            .foregroundStyle(Color.Text.secondary)
            .buttonStyle(.plain)

            Button {} label: {
                HStack(spacing: 4) {
                    Image("ic_comment")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("\(json.comment_count.int ?? 0)")
                        .font(.system(size: 14))
                        .padding(.leading, 5)
                }
            }
            .foregroundStyle(Color.Text.secondary)
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            if !showsPremiumOverlay {
                Button { } label: {
                    HStack(spacing: 4) {
                        Image("ic_share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("\(json.share_count.int ?? 0)")
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)

                Button {} label: {
                    Image("ic_save")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(Color.Text.secondary)
                .buttonStyle(.plain)
            }
        }
        .font(.system(size: 14))
        .padding(.top, 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FeedPostViewArtist()
            .padding(.top, 16)
            .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}
