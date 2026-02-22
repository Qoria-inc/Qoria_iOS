//
//  FeedMediaImage.swift
//  Qoria_App
//
//  Displays feed media from either a URL (API) or an asset name (placeholder).
//

import SwiftUI

struct FeedMediaImage: View {
    let source: String
    var placeholderAsset: String = "ic_postImg1"

    private var isURL: Bool {
        source.hasPrefix("http://") || source.hasPrefix("https://")
    }

    var body: some View {
        if isURL, let url = URL(string: source) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(placeholderAsset)
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Image(placeholderAsset)
                        .resizable()
                        .scaledToFill()
                @unknown default:
                    Image(placeholderAsset)
                        .resizable()
                        .scaledToFill()
                }
            }
        } else {
            Image(source)
                .resizable()
                .scaledToFill()
        }
    }
}
