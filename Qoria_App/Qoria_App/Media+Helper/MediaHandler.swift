//
//  MediaHandler.swift
//  Qoria_App
//
//  Created by Sharif Rafi on 3/3/26.
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit

// MARK: - Feed Post Media View

/// Images 1–3, single HLS video, or two HLS videos side by side.
struct FeedPostMediaView: View {
    var media: FeedPostMediaKind
    var competitionStatusTitle: String?
    var isInCenter: Bool = false
    var showsPremiumOverlay: Bool

    @State private var singleIsMuted = true
    @State private var leftIsMuted = true
    @State private var rightIsMuted = true
    @State private var currentImageIndex: Int = 0
    @State private var scrollPosition: Int? = 0

    private let containerSize = UIScreen.main.bounds.width
    private let twoVideosLeadingTrailingPadding: CGFloat = 4
    private let twoVideosMiddleSpacing: CGFloat = 4

    var body: some View {
        Group {
            switch media {
            case .images(let items):
                imagesLayout(items: items)
            case .singleVideo(let hlsURL, let thumbnailURL):
                singleVideoLayout(hlsURL: hlsURL, thumbnailURL: thumbnailURL)
            case .twoVideos(let left, let right, let leftThumb, let rightThumb):
                twoVideosLayout(left: left, right: right, leftThumbnail: leftThumb, rightThumbnail: rightThumb)
            }
        }
        .frame(width: containerSize, height: containerSize)
        .overlay(alignment: .bottom) {
            mediaOverlay
        }
        .overlay {
            if showsPremiumOverlay {
                PremiumLockedOverlayView()
            }
        }
        .padding(.horizontal, -16)
    }

    // MARK: Images Layout

    @ViewBuilder
    private func imagesLayout(items: [String]) -> some View {
        let safeItems = Array(items.prefix(3))
        ZStack {
            Color.Surface.appBackground
            if safeItems.isEmpty {
                FeedMediaImage(source: "ic_postImg1")
                    .frame(width: containerSize, height: containerSize)
                    .clipped()
            } else if safeItems.count == 1 {
                FeedMediaImage(source: safeItems[0])
                    .frame(width: containerSize, height: containerSize)
                    .clipped()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(safeItems.enumerated()), id: \.offset) { index, src in
                            FeedMediaImage(source: src)
                                .frame(width: containerSize, height: containerSize)
                                .clipped()
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPosition)
                .frame(width: containerSize, height: containerSize)
                .clipped()
                .onChange(of: scrollPosition) { _, newValue in
                    if let idx = newValue { currentImageIndex = idx }
                }
                .overlay(alignment: .bottom) {
                    imagePageIndicator(count: safeItems.count)
                }
            }
        }
    }

    private func imagePageIndicator(count: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: Single Video Layout

    private func singleVideoLayout(hlsURL: String, thumbnailURL: String?) -> some View {
        FeedVideoCellView(
            urlString: hlsURL,
            thumbnailURL: thumbnailURL,
            isInCenter: isInCenter && !showsPremiumOverlay,
            isMuted: $singleIsMuted,
            showVolumeButton: true
        )
        .frame(width: containerSize, height: containerSize)
    }

    // MARK: Two Videos Layout

    /// Leading/trailing 5pt padding, 3pt spacing between videos.
    private func twoVideosLayout(left: String, right: String, leftThumbnail: String?, rightThumbnail: String?) -> some View {
        let totalHorizontalPadding = twoVideosLeadingTrailingPadding * 2 + twoVideosMiddleSpacing
        let halfWidth = (containerSize - totalHorizontalPadding) / 2
        return ZStack {
            Color.Surface.appBackground
            HStack(spacing: twoVideosMiddleSpacing) {
                FeedVideoCellView(
                    urlString: left,
                    thumbnailURL: leftThumbnail,
                    isInCenter: isInCenter && !showsPremiumOverlay,
                    isMuted: $leftIsMuted,
                    showVolumeButton: false
                )
                .frame(width: halfWidth, height: containerSize)
                .clipped()
                .cornerRadius(10)
                FeedVideoCellView(
                    urlString: right,
                    thumbnailURL: rightThumbnail,
                    isInCenter: isInCenter && !showsPremiumOverlay,
                    isMuted: $rightIsMuted,
                    showVolumeButton: false
                )
                .frame(width: halfWidth, height: containerSize)
                .clipped()
                .cornerRadius(10)
            }
            .padding(.leading, twoVideosLeadingTrailingPadding)
            .padding(.trailing, twoVideosLeadingTrailingPadding)
        }
    }

    // MARK: Media Overlay

    @ViewBuilder
    private var mediaOverlay: some View {
        ZStack(alignment: .bottomTrailing) {
            if let title = competitionStatusTitle {
                HStack {
                    Spacer()
                    CompetitionStatusButtonView(title: title)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            switch media {
            case .singleVideo:
                EmptyView()
            case .twoVideos:
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        volumeButton(toggleLeft: $leftIsMuted, toggleRight: $rightIsMuted)
                            .padding(10)
                    }
                }
            case .images:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func volumeButton(toggleLeft: Binding<Bool>, toggleRight: Binding<Bool>) -> some View {
        Button {
            let next = !toggleLeft.wrappedValue
            toggleLeft.wrappedValue = next
            toggleRight.wrappedValue = next
        } label: {
            Image(systemName: toggleLeft.wrappedValue ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.5), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feed Video Cell View

/// Single video cell: thumbnail until loaded, then video; auto-play when in center; optional volume in cell.
private struct FeedVideoCellView: View {
    let urlString: String
    var thumbnailURL: String? = nil
    let isInCenter: Bool
    @Binding var isMuted: Bool
    var showVolumeButton: Bool = true
    @State private var isVideoReady = false

    var body: some View {
        ZStack {
            Color.Surface.appBackground
            if let thumb = thumbnailURL, !thumb.isEmpty {
                FeedMediaImage(source: thumb)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .opacity(isVideoReady ? 0 : 1)
                    .animation(.easeOut(duration: 0.2), value: isVideoReady)
            }
            FeedHLSVideoPlayer(
                urlString: urlString,
                shouldPlay: isInCenter,
                isMuted: isMuted,
                isReadyForDisplay: $isVideoReady
            )

            if showVolumeButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            $isMuted.wrappedValue = !$isMuted.wrappedValue
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.5), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                }
            }
        }
    }
}

// MARK: - HLS Video Player

/// AVPlayer wrapper – play/pause from scroll position, mute by default.
private struct FeedHLSVideoPlayer: View {
    let urlString: String
    var shouldPlay: Bool = true
    var isMuted: Bool = true
    @Binding var isReadyForDisplay: Bool

    var body: some View {
        FeedHLSVideoPlayerRepresentable(urlString: urlString, shouldPlay: shouldPlay, isMuted: isMuted, isReadyForDisplay: $isReadyForDisplay)
    }
}

// MARK: - HLS Video Player Representable

private struct FeedHLSVideoPlayerRepresentable: UIViewRepresentable {
    let urlString: String
    var shouldPlay: Bool
    var isMuted: Bool
    @Binding var isReadyForDisplay: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isReadyForDisplay: $isReadyForDisplay)
    }

    func makeUIView(context: Context) -> UIView {
        let view = PlayerView()
        let coord = context.coordinator
        view.onReadyForDisplay = {
            DispatchQueue.main.async {
                coord.isReadyForDisplay.wrappedValue = true
            }
        }
        // Configure immediately to start loading/buffering before the cell reaches center.
        view.configure(urlString: urlString, shouldPlay: shouldPlay)
        view.setMuted(isMuted)
        view.applyPlayPause(shouldPlay: shouldPlay)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let playerView = uiView as? PlayerView else { return }
        let coord = context.coordinator
        playerView.onReadyForDisplay = {
            DispatchQueue.main.async {
                coord.isReadyForDisplay.wrappedValue = true
            }
        }
        if shouldPlay {
            playerView.cancelTearDown()
            if playerView.currentURLString != urlString {
                playerView.configure(urlString: urlString, shouldPlay: true)
            }
            playerView.setMuted(isMuted)
            playerView.applyPlayPause(shouldPlay: true)
        } else {
            playerView.cancelTearDown()
            if playerView.currentURLString != urlString {
                playerView.configure(urlString: urlString, shouldPlay: false)
            }
            playerView.setMuted(isMuted)
            playerView.applyPlayPause(shouldPlay: false)
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        guard let playerView = uiView as? PlayerView else { return }
        coordinator.isReadyForDisplay.wrappedValue = false
        playerView.performImmediateTearDown()
    }

    class Coordinator {
        var isReadyForDisplay: Binding<Bool>
        init(isReadyForDisplay: Binding<Bool>) {
            self.isReadyForDisplay = isReadyForDisplay
        }
    }
}

// MARK: - Player View (AVPlayer UIKit Bridge)

private final class PlayerView: UIView {
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var readyForDisplayObserver: NSKeyValueObservation?
    private var endObserver: Any?
    private var tearDownWorkItem: DispatchWorkItem?
    private(set) var currentURLString: String = ""
    private var pendingShouldPlay: Bool = false
    var onReadyForDisplay: (() -> Void)?

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer = layer as? AVPlayerLayer
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        playerLayer = layer as? AVPlayerLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    // MARK: Configuration

    func configure(urlString: String, shouldPlay: Bool = false) {
        guard let url = URL(string: urlString), urlString.hasPrefix("http") else {
            removeEndObserver()
            statusObserver = nil
            playerLayer?.player = nil
            player = nil
            currentURLString = ""
            return
        }
        removeEndObserver()
        statusObserver = nil
        readyForDisplayObserver = nil
        currentURLString = urlString
        pendingShouldPlay = shouldPlay
        FeedVideoAudioSession.configureOnce()
        let item = AVPlayerItem(url: url)
        // Prioritize quick startup over deep prebuffer.
        item.preferredForwardBufferDuration = 0
        item.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.automaticallyWaitsToMinimizeStalling = false
        newPlayer.isMuted = true
        playerLayer?.player = newPlayer
        playerLayer?.videoGravity = .resizeAspectFill
        player = newPlayer

        readyForDisplayObserver = playerLayer?.observe(\.isReadyForDisplay, options: [.new]) { [weak self] layer, _ in
            guard (layer as AVPlayerLayer).isReadyForDisplay == true else { return }
            DispatchQueue.main.async { self?.onReadyForDisplay?() }
        }

        statusObserver = item.observe(\.status, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.itemStatusDidChange()
            }
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.replayFromBeginning()
        }
        if item.status == .readyToPlay {
            applyPlayPause(shouldPlay: shouldPlay)
        }
    }

    // MARK: Teardown

    private func removeEndObserver() {
        if let o = endObserver {
            NotificationCenter.default.removeObserver(o)
            endObserver = nil
        }
    }

    func cancelTearDown() {
        tearDownWorkItem?.cancel()
        tearDownWorkItem = nil
    }

    /// Defer teardown slightly to avoid FigApplicationStateMonitor / PlayerRemoteXPC errors from rapid create/destroy.
    func scheduleTearDown() {
        cancelTearDown()
        player?.pause()
        let item = DispatchWorkItem { [weak self] in
            self?.performTearDown()
        }
        tearDownWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: item)
    }

    /// Release player and observers when scrolled out of center.
    private func performTearDown() {
        tearDownWorkItem = nil
        pendingShouldPlay = false
        removeEndObserver()
        statusObserver = nil
        readyForDisplayObserver = nil
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer?.player = nil
        currentURLString = ""
    }

    func performImmediateTearDown() {
        cancelTearDown()
        performTearDown()
    }

    // MARK: Playback

    private func replayFromBeginning() {
        guard pendingShouldPlay else { return }
        player?.seek(to: .zero) { [weak self] finished in
            guard finished else { return }
            self?.player?.play()
        }
    }

    private func itemStatusDidChange() {
        guard let item = player?.currentItem, item.status == .readyToPlay else { return }
        applyPlayPause(shouldPlay: pendingShouldPlay)
    }

    func applyPlayPause(shouldPlay: Bool) {
        pendingShouldPlay = shouldPlay
        guard player != nil else { return }
        if shouldPlay {
            player?.playImmediately(atRate: 1.0)
        } else {
            player?.pause()
        }
    }

    func setMuted(_ muted: Bool) {
        player?.isMuted = muted
    }

    deinit {
        cancelTearDown()
        removeEndObserver()
        statusObserver = nil
        player?.pause()
        player = nil
        playerLayer?.player = nil
    }
}
