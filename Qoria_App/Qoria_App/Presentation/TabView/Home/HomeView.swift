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
                    ForEach(0..<images.count, id: \.self) { i in
                        FeedPostView(image: images[i])
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
