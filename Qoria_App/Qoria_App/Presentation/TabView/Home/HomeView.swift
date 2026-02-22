//
//  HomeView.swift
//  Qoria_App
//

import SwiftUI

// MARK: - Post view mapping (API item → UI)
private enum UserCategory {
    case pro, nonPro, none
}

private enum proUserFeed {
    case teacher, artist, teacherAndArtist, none
}

private enum nonProUserFeed {
    case student, fan, studentAndFan, none
}

struct HomeView: View {
    
    // MARK: - State
    @StateObject private var viewModel: HomeViewModel
    @State private var isBannerVisible = true
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            
            QoriaAppBarView(
                onProfileTap: {},
                onNotificationTap: {},
                onChatTap: {}
            )
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    if isBannerVisible {
                        PremiumBannerView(onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                isBannerVisible = false
                            }
                        })
                    }
                    ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        postView(for: item)
                            .onAppear {
                                Task {
                                    await viewModel.loadNextPageIfNeeded(currentIndex: index)
                                }
                            }
                    }

                    if viewModel.isLoading && viewModel.items.isEmpty {
                        ProgressView("Loading feed…")
                            .frame(maxWidth: .infinity)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    } else if viewModel.isLoadingMore {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 24)
                .scrollIndicators(.hidden)
            }
            .background(Color.Surface.appBackground)
        }
    }

    // Mark: - Dynamic Post Type
    @ViewBuilder
    private func postView(for json: dynamicJSON) -> some View {
        
        let userCategory: UserCategory = {
            switch json.owner_info.user_type.int ?? 0 {
            case 1: return .pro
            case 2: return .nonPro
            default: return .none
            }
        }()
        
        let proFeedType: proUserFeed = {
            switch json.owner_info.teachable.int ?? 0 {
            case 0: return .artist
            case 1: return .teacher
            case 2: return .teacherAndArtist
            default: return .none
            }
        }()
        
        let nonProFeedType: nonProUserFeed = {
            switch json.owner_info.student_type.int ?? 0 {
            case 1: return .student
            case 2: return .fan
            case 3: return .studentAndFan
            default: return .none
            }
        }()
        
        let postID = json.id.string ?? ""

        let userName = json.owner_info.name.string ?? ""
        let userProfileImage = json.owner_info.avatar.string ?? ""
        let userId = json.owner_id.string ?? ""
        let postTitle = json.title.string ?? ""
        let postTime = json.created_at.string ?? ""
        //let competationStatus = ""
        
        let images = [json.photo1.string ?? "", json.photo2.string ?? "", json.photo3.string ?? ""]
        let firstVideo = json.processed_video_hls.string ?? ""
        let firstVideoThumbnail = json.processed_video_thumbnail.string ?? ""
        let secondVideo = json.processed_after_video_hls.string ?? ""
        let secondVideoThumbnail = json.processed_after_video_thumbnail.string ?? ""
        
        let reactCount = json.like_count.int ?? 0
        let commentCount = json.comment_count.int ?? 0
        let shareCount = json.share_count.int ?? 0
        
        let trophieCount = json.trophies.int ?? 0
        
        let isPostReacted = json.is_liked.bool
        let isPostSaved = json.is_saved.bool
        let isPostShared = json.is_shared.bool
        let isPostReported = json.is_reported.bool
        let isPostRestricted = json.is_restricted.bool
        
        //let sharedByInFollowing = [json.shared_by_in_following]
        
        let isFeedbackEnable = json.enable_feedback.bool
        let isFromTeacher = json.is_from_teacher.bool
        
        let isChallenge = json.is_challenge.bool
        let isChallengeWinner = json.is_challenge_winner.bool
        let isChallengeOpen = json.is_challenge_open.bool

        if userCategory == .pro {
            switch proFeedType {
            case .teacher:
                FeedPostViewTeacher()
            case .artist:
                FeedPostViewArtist()
            case .teacherAndArtist:
                FeedPostViewTeacherAndArtist()
            case .none:
                EmptyView()
            }
        }
        else {
            switch nonProFeedType {
            case .student:
                FeedPostViewStudent()
            case .fan:
                FeedPostViewStudent()
            case .studentAndFan:
                FeedPostViewStudent()
            case .none:
                EmptyView()
            }
        }
    }
}

#Preview {
    let repo = HomeRepositoryImpl()
    let useCase = GetHomeDataUseCase(repository: repo)
    let vm = HomeViewModel(getHomeDataUseCase: useCase)
    return HomeView(viewModel: vm)
}
