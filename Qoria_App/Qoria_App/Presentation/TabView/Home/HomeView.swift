//
//  HomeView.swift
//  Qoria_App
//

import SwiftUI

// MARK: - Dummy feed model (replace with API model later)

private enum FeedUserType: String, CaseIterable {
    case teacher
    case artist
    case student
    case teacherAndArtist
}

private struct FeedPostItem: Identifiable {
    let id: UUID
    let image: String
    let images: [String]? // Optional array for multiple images (e.g., side-by-side)
    let userType: FeedUserType
    let showsLearnThis: Bool
    let competitionStatusTitle: String?
    let competitionCurrentStatusTitle: String?

    init(
        id: UUID = UUID(),
        image: String,
        images: [String]? = nil,
        userType: FeedUserType,
        showsLearnThis: Bool = false,
        competitionStatusTitle: String? = nil,
        competitionCurrentStatusTitle: String? = nil
    ) {
        self.id = id
        self.image = image
        self.images = images
        self.userType = userType
        self.showsLearnThis = showsLearnThis
        self.competitionStatusTitle = competitionStatusTitle
        self.competitionCurrentStatusTitle = competitionCurrentStatusTitle
    }
}

struct HomeView: View {

    // MARK: - State

    @StateObject private var viewModel: HomeViewModel
    @State private var isBannerVisible = true

    /// Dummy feed items: mix of teacher, artist, student, teacherAndArtist posts.
    /// Bottom 3 show competition CTA buttons with different labels.
    private let feedItems: [FeedPostItem] = [
        FeedPostItem(image: "ic_postImg1", userType: .teacher, showsLearnThis: true),
        FeedPostItem(image: "ic_postImg2", userType: .artist),
        FeedPostItem(image: "ic_postImg1", userType: .student),
        // Student post with 2 images side-by-side
        FeedPostItem(
            image: "ic_postImg1",
            images: ["ic_postImg1", "ic_postImg2"],
            userType: .student
        ),
        // Bottom 3 competition CTAs
        FeedPostItem(
            image: "ic_postImg2",
            images: ["ic_postImg1", "ic_postImg2"],
            userType: .teacherAndArtist,
            competitionStatusTitle: "Winners Pending",
            competitionCurrentStatusTitle: "Voting is over"
        ),
        FeedPostItem(
            image: "ic_postImg1",
            images: ["ic_postImg2", "ic_postImg1"],
            userType: .teacher,
            competitionStatusTitle: "See Winners",
            competitionCurrentStatusTitle: "Winners Announced"
        ),
        FeedPostItem(
            image: "ic_postImg2",
            userType: .artist,
            competitionStatusTitle: "See the Competition",
            competitionCurrentStatusTitle: "Voting ends in 4h"
        ),
        FeedPostItem(image: "ic_postImg1", userType: .student),
        FeedPostItem(image: "ic_postImg2", userType: .teacherAndArtist),
    ]
    
    // MARK: - Init (simple manual DI)
    
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
            Color.clear.frame(height: 14)
            ScrollView {
                LazyVStack(spacing: 20) {
                    if isBannerVisible {
                        PremiumBannerView(onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                isBannerVisible = false
                            }
                        })
                    }
                    // ForEach(0..<images.count, id: \.self) { i in
                    //     FeedPostView(image: images[i])}
                    ForEach(feedItems) { item in
                        switch item.userType {
                        case .teacher:
                            FeedPostView(
                                image: item.image,
                                images: item.images,
                                showsLearnThis: item.showsLearnThis,
                                competitionStatusTitle: item.competitionStatusTitle,
                                competitionCurrentStatusTitle: item.competitionCurrentStatusTitle
                            )
                        case .artist:
                            FeedPostViewArtist(
                                image: item.image,
                                images: item.images,
                                competitionStatusTitle: item.competitionStatusTitle,
                                competitionCurrentStatusTitle: item.competitionCurrentStatusTitle
                            )
                        case .student:
                            FeedPostViewStudent(
                                image: item.image,
                                images: item.images
                            )
                        case .teacherAndArtist:
                            FeedPostViewTeacherAndArtist(
                                image: item.image,
                                images: item.images,
                                showsLearnThis: item.showsLearnThis,
                                competitionStatusTitle: item.competitionStatusTitle,
                                competitionCurrentStatusTitle: item.competitionCurrentStatusTitle
                            )
                        }
                    }
                    
                    // Optional debug section to verify Home API
                    if viewModel.isLoading {
                        ProgressView("Loading feed…")
                            .frame(maxWidth: .infinity)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    } else if let data = viewModel.homeData {
                        Text(data.description)
                            .font(.footnote.monospaced())
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.Surface.appBar)
        .task {
            self.viewModel.loadHome()
        }
    }
}

#Preview {
    let repo = HomeRepositoryImpl()
    let useCase = GetHomeDataUseCase(repository: repo)
    let vm = HomeViewModel(getHomeDataUseCase: useCase)
    return HomeView(viewModel: vm)
}
