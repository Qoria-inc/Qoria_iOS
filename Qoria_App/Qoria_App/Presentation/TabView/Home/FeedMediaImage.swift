//
//  FeedMediaImage.swift
//  Qoria_App
//
//  Displays feed media from either a URL (API) or an asset name (placeholder).
//  Uses in-memory cache for smooth scrolling.
//

import SwiftUI

// MARK: - In-memory image cache for feed (images + video thumbnails)
enum FeedImageCache {
    private static let cache: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 80
        c.totalCostLimit = 80 * 1024 * 1024
        return c
    }()

    static func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    static func set(_ image: UIImage, for key: String) {
        let cost = image.jpegData(compressionQuality: 0.8)?.count ?? (image.cgImage?.bytesPerRow ?? 0) * (image.cgImage?.height ?? 0)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
}

struct FeedMediaImage: View {
    let source: String
    var placeholderAsset: String = "ic_postImg1"

    private var isURL: Bool {
        source.hasPrefix("http://") || source.hasPrefix("https://")
    }

    var body: some View {
        if isURL, let url = URL(string: source) {
            CachedFeedImageView(url: url, placeholderAsset: placeholderAsset)
        } else {
            Image(source)
                .resizable()
                .scaledToFill()
        }
    }
}

// MARK: - Cached image load (cache-first for smooth scrolling)
private struct CachedFeedImageView: View {
    let url: URL
    var placeholderAsset: String = "ic_postImg1"
    @State private var image: UIImage?
    @State private var loadTask: URLSessionDataTask?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(placeholderAsset)
                    .resizable()
                    .scaledToFill()
                    .onAppear { loadImage() }
            }
        }
    }

    private func loadImage() {
        let key = url.absoluteString
        if let cached = FeedImageCache.image(for: key) {
            image = cached
            return
        }
        loadTask?.cancel()
        loadTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let uiImage = UIImage(data: data) else { return }
            FeedImageCache.set(uiImage, for: key)
            DispatchQueue.main.async { image = uiImage }
        }
        loadTask?.resume()
    }
}
