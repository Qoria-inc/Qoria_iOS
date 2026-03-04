//
//  FeedPostViewTeacherAndArtist.swift
//  Qoria_App
//
//  Feed post content view for Teacher/Artist user type. Layout identical to Teacher (FeedPostView).
//

import SwiftUI

struct FeedPostViewTeacherAndArtist: View {
    
    // MARK: Inputs
    var focusedMediaPostIndex: Int? = nil
    var postIndex: Int = 0

    var json: dynamicJSON = dynamicJSON()
    var showsLearnThis: Bool = false
    var showsPremiumOverlay: Bool = false
    var isEmbedded: Bool = false

    // MARK: Body

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: UIScreen.main.bounds.width - (isEmbedded ? 24 : 0), alignment: .leading)
            .clipped()
            .background(Color.Surface.post)
    }
}

// MARK: - FeedPostViewTeacher&Artist Layout

private extension FeedPostViewTeacherAndArtist {
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

            if !isEmbedded {moreButton}
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
                        LinearGradient(colors: [Color.Profile.teacherArtistPurple.opacity(0.60),Color.Gradient.proStart.opacity(0.50)], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    .frame(width: 52, height: 52)

                FeedMediaImage(source: json.owner_info.avatar.string ?? "")
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

                Text("Teacher/Artist")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.Text.onDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(colors: [Color.Gradient.proStart.opacity(0.40), Color.Profile.teacherArtistPurple.opacity(0.50)], startPoint: .leading, endPoint: .trailing), in: Capsule())
                    .overlay(
                        Capsule().stroke(AngularGradient(colors: [Color.Profile.teacherArtistPurple.opacity(0.40), Color.Gradient.proStart.opacity(0.30)], center: .center), lineWidth: 0.5))

                FeedContentTypeView(isSingleTrophy: json.post_type.int == 1
                                    ? true : false,
                                    isLock: json.post_type.int == 5 ? true : false)
            }

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

            // Learn This CTA sits BELOW the media (not over it)
            if showsLearnThis {
                LearnThisButtonView {}
                    .padding(.horizontal, -16)
            }
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
        FeedPostViewTeacherAndArtist()
            .padding(.top, 16)
            .padding(.horizontal, 0)
    }
    .preferredColorScheme(.dark)
}
