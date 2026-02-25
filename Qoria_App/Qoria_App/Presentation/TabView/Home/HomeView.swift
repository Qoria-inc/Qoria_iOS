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

private enum feedPostType {
    case regular, challenge, submission, lounge, premiumArtist, premiumTutorial, system, gallery, sharedCourse, none
}

struct HomeView: View {
    
    // MARK: - State
    @StateObject private var viewModel: HomeViewModel
    @State private var isBannerVisible = true
    @State private var focusedMediaPostIndex: Int? = nil
    
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
                        postView(for: item, index: index, focusedMediaPostIndex: focusedMediaPostIndex)
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
                .onPreferenceChange(MediaFramesPreferenceKey.self) { frames in
                    let screenMidY = UIScreen.main.bounds.midY
                    let threshold: CGFloat = UIScreen.main.bounds.height * 0.35
                    focusedMediaPostIndex = frames
                        .filter { abs($0.value.midY - screenMidY) < threshold }
                        .min(by: { abs($0.value.midY - screenMidY) < abs($1.value.midY - screenMidY) })
                        .map(\.key)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(Color.Surface.appBackground)
        }
    }

    // Mark: - Dynamic Post Type
    @ViewBuilder
    private func postView(for json: dynamicJSON, index: Int, focusedMediaPostIndex: Int?) -> some View {
        
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
        
        let postType: feedPostType = {
            switch json.post_type.int ?? 0 {
            case 0: return .regular
            case 1: return .challenge
            case 2: return .submission
            case 3: return .lounge
            case 4: return .premiumArtist
            case 5: return .premiumTutorial
            case 6: return .system
            case 7: return .gallery
            case 8: return .sharedCourse
            default: return .none
            }
        }()
        
//        let postID = json.id.string ?? ""
//
//        let userName = json.owner_info.name.string ?? ""
//        let userProfileImage = json.owner_info.avatar.string ?? ""
//        let userId = json.owner_id.string ?? ""
//        let postTitle = json.title.string ?? ""
//        let postTime = json.created_at.string ?? ""
//        //let competationStatus = ""
//        
//        let images = (json.images.array ?? []).compactMap { $0.url.string }.filter { !$0.isEmpty }
//        let firstVideo = json.processed_video_hls.string ?? ""
//        let firstVideoThumbnail = json.processed_video_thumbnail.string ?? ""
//        let secondVideo = json.processed_after_video_hls.string ?? ""
//        let secondVideoThumbnail = json.processed_after_video_thumbnail.string ?? ""
//        
//        let reactCount = json.like_count.int ?? 0
//        let commentCount = json.comment_count.int ?? 0
//        let shareCount = json.share_count.int ?? 0
//        
//        let trophieCount = json.trophies.int ?? 0
//        
//        let isPostReacted = json.is_liked.bool
//        let isPostSaved = json.is_saved.bool
//        let isPostShared = json.is_shared.bool
//        let isPostReported = json.is_reported.bool
//        let isPostRestricted = json.is_restricted.bool
//        
//        //let sharedByInFollowing = [json.shared_by_in_following]
//        
//        let isFeedbackEnable = json.enable_feedback.bool
//        let isFromTeacher = json.is_from_teacher.bool
//        
//        let isChallenge = json.is_challenge.bool
//        let isChallengeWinner = json.is_challenge_winner.bool
//        let isChallengeOpen = json.is_challenge_open.bool

        if userCategory == .pro {
            switch proFeedType {
            case .teacher:
                switch postType {
                case .regular:
                    FeedPostViewTeacher(
                        focusedMediaPostIndex: focusedMediaPostIndex,
                        postIndex: index,
                        json: json,
                        showsPremiumOverlay: index == 0
                    )
                case .challenge:
                    FeedPostViewTeacher(
                        focusedMediaPostIndex: focusedMediaPostIndex,
                        postIndex: index,
                        json: json,
                        showsPremiumOverlay: index == 0
                    )
                case .premiumTutorial:
                    FeedPostViewTeacher(
                        focusedMediaPostIndex: focusedMediaPostIndex,
                        postIndex: index,
                        json: json,
                        showsPremiumOverlay: index == 0
                    )
                default:
                    EmptyView()
                }
            case .artist:
                switch postType {
                case .regular:
                    FeedPostViewArtist()
                case .challenge:
                    FeedPostViewArtist()
                case .premiumArtist:
                    FeedPostViewArtist()
                default:
                    EmptyView()
                }
            case .teacherAndArtist:
                switch postType {
                case .regular:
                    FeedPostViewTeacherAndArtist()
                case .challenge:
                    FeedPostViewTeacherAndArtist()
                case .premiumTutorial, .premiumArtist:
                    FeedPostViewTeacherAndArtist()
                default:
                    EmptyView()
                }
            case .none:
                EmptyView()
            }
        }
        else {
            switch nonProFeedType {
            case .student:
                switch postType {
                case .regular:
                    FeedPostViewStudent()
                case .submission:
                    FeedPostViewStudent()
                default:
                    EmptyView()
                }
            case .fan:
                switch postType {
                case .regular:
                    FeedPostViewStudent()
                default:
                    EmptyView()
                }
            case .studentAndFan:
                switch postType {
                case .regular:
                    FeedPostViewStudent()
                case .submission:
                    FeedPostViewStudent()
                default:
                    EmptyView()
                }
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
