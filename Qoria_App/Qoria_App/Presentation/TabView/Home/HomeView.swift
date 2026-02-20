//
//  HomeView.swift
//  qoria_dev
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - State
    
    @StateObject private var viewModel: HomeViewModel
    @State private var isBannerVisible = true
    
    let images = ["ic_postImg1", "ic_postImg2", "ic_postImg1", "ic_postImg2", "ic_postImg1", "ic_postImg2", "ic_postImg1", "ic_postImg2"]
    
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
                    
                    ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        FeedPostView(image: images[index % images.count])
                            .onAppear {
                                Task {
                                    await viewModel.loadNextPageIfNeeded(currentIndex: index)
                                }
                            }
                    }
                    
                    // Optional debug section to verify Home API
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
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.Surface.appBar)
    }
}

#Preview {
    let repo = HomeRepositoryImpl()
    let useCase = GetHomeDataUseCase(repository: repo)
    let vm = HomeViewModel(getHomeDataUseCase: useCase)
    return HomeView(viewModel: vm)
}
