//
//  HomeView.swift
//  qoria_dev
//

import SwiftUI

struct HomeView: View {
    
    @State private var isBannerVisible = true
    let images = ["ic_postImg1", "ic_postImg2", "ic_postImg1", "ic_postImg2", "ic_postImg1", "ic_postImg2", "ic_postImg1", "ic_postImg2"]
    
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
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.Surface.appBar)
    }
}

#Preview {
    HomeView()
}
